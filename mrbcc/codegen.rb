# encoding: utf-8
require 'active_support/core_ext'
require 'securerandom'
require_relative './rite_parser'

class OpcodeParser
  attr_reader :name, :irep, :opcodes
  DEBUG_MODE = false
  DEBUG_MODE_VERBOSE = DEBUG_MODE && false
  def initialize(parser, opcodes, name, irep_idx)
    @name = name || "met_#{SecureRandom.hex}"
    @irep = parser.ireps[irep_idx]
    @parser = parser
    @irep_idx = irep_idx
    @opcodes = opcodes
    @prepend_compiled_ireps = []
  end

  def label(i)
    @instructions_referenced[i] = true
    "L_#{@name.upcase}_#{i}"
  end

  def instructions_to_function(instruction_bodies)
    outio = StringIO.new

    @prepend_compiled_ireps.reverse.each do |str|
      outio.write(str)
      outio.write("\n")
    end

    outio.write(method_prelude)
    instruction_bodies.each.with_index do |str, idx|
      outio.write("\n  // #{irep.iseqs[idx]}\n")

      if @instructions_referenced[idx] || OpcodeParser::DEBUG_MODE
        outio.write("  #{label(idx)}:")
      end

      outio.write("\n  ");

      if OpcodeParser::DEBUG_MODE
        outio.write("  printf(\"#{label(idx)}\\n\"); fflush(stdout);\n")
        str2 = <<-EOF
        printf("X#{label(idx).strip}\\nXstack ptr \%d\\n", mrb->stack - mrb->stbase);
        printf("Xregs ptr \%d\\n", regs - mrb->stack);
        EOF
        #outio.write(str2)
      end

      outio.write(str)
    end
    outio.write(method_epilogue)

    outio.string
  end

  def process_irep
    instruction_bodies = [] # C code for each opcode
    @instructions_referenced = [] # true or false if the opcode needs a label

    irep.iseqs.each.with_index do |instr, line_number|
      puts instr if DEBUG_MODE_VERBOSE

      @instr = instr
      @line_number = line_number
      @opcode = instr.opcode

      @instructions_referenced[@line_number] ||= false

      @instr_body = opcodes[@opcode].dup
      if respond_to?(@opcode.downcase)
        send(@opcode.downcase)
      end

      gsub_args

      # symbols
      @instr_body.gsub!(/syms\[([^\]]+)\]/) do
        "mrb_intern(mrb, \"#{irep.syms[$1.to_i]}\")"
      end
      # string literals
      @instr_body.gsub!(/mrb_str_literal\(mrb, (pool\[[^\]]+\])\)/) do
        $1
      end
      # pool
      @instr_body.gsub!(/pool\[([^\]]+)\]/) do
        val = irep.pool[$1.to_i]
        val = case val
        when Float
          "mrb_float_value(#{val})"
        when Numeric
          "mrb_fixnum_value(#{val})"
        when String
          # TODO fix this so we can load binary strings too
          val.gsub!('"', '\\"');
          "mrb_str_new_cstr(mrb, \"#{val}\")"
        when Regexp
          # TODO
          raise
        else
          val
        end
      end
      # raise
      @instr_body.gsub!("goto L_RAISE;", "mrbb_raise(mrb, prev_jmp);")

      instruction_bodies[@line_number] = @instr_body

    end
    instructions_to_function(instruction_bodies)
  end

  def method_epilogue
    body = "\n"
    if @irep_idx == 0
      # TODO look at OP_STOP?
      body += "  return mrb_nil_value();\n"
    else
      body += "  printf(\"ERROR: Method #{@name} did not return.\\n\");\n"
      body += "  exit(1);\n" # so we don't get warnings about no return
    end
    body += "}\n"
  end

  def method_prelude
    prelude = File.read(File.expand_path("../codegen_rb/met_start.c", __FILE__))
    prelude.gsub("FUNC_NREGS", irep.nregs.to_s).
      gsub("MET_NAME", @name)
  end

  def gsub_args
    ["GETARG_A", "GETARG_Ax"].each do |search_str|
      @instr_body.gsub!("#{search_str}(i)", @instr.send(search_str).to_s)
    end
    ["GETARG_B", "GETARG_Bx", "GETARG_sBx", "GETARG_b"].each do |search_str|
      @instr_body.gsub!("#{search_str}(i)", @instr.send(search_str).to_s)
    end
    ["GETARG_C", "GETARG_c"].each do |search_str|
      @instr_body.gsub!("#{search_str}(i)", @instr.send(search_str).to_s)
    end
  end

  def fix_lsend_2arg(met_name)
    @instr_body.gsub!("goto L_SEND;",
      "regs[a] = mrb_funcall_with_block(mrb, regs[a], " +
      "mrb_intern(mrb, \"#{met_name}\"), 1, &regs[a+1], mrb_nil_value());")
  end

  def lambda_arg_precompiled(parser, arg_name)
    @instr_body.gsub!("#{arg_name}(i)", parser.name)
    @instr_body.gsub!("GETIREP_BLK_NREGS()", parser.irep.nregs.to_s)
    @instr_body.gsub!("GETIREP_NLOCALS()", @irep.nlocals.to_s)
  end

  def lambda_arg(arg_name)
    # only for readability / easier debugging, try to include method name
    # TODO: doesn't work right always (infinite recursion for example, wrong name)
    if irep.iseqs[@line_number+1].present? &&
      irep.iseqs[@line_number+1].opcode == "OP_METHOD"
      iseq_met = irep.iseqs[@line_number+1]
      met_name = irep.syms[iseq_met.GETARG_B]
      met_name = met_name.gsub(/[^\w\d_]/, "") # strip stuff like ?, ! from name
      met_name = "met_#{met_name}_#{SecureRandom.hex}"
    else
      met_name = nil
    end

    parser = OpcodeParser.new(@parser, opcodes, met_name, @irep_idx + @instr.send(arg_name))
    @prepend_compiled_ireps.push(parser.process_irep)
    lambda_arg_precompiled(parser, arg_name)
    parser
  end
# OPCODES
  def op_exec
    lambda_arg("GETARG_Bx")
  end

  def op_lambda
    lambda_arg("GETARG_b")
  end

  def op_epush
    @ensure_parser = lambda_arg("GETARG_Bx")
  end

  def op_return
    # todo
  end

  def op_send
  end

  def op_sendb
    op_send
  end

  def op_sub
    fix_lsend_2arg("-")
  end

  def op_add
    fix_lsend_2arg("+")
  end

  def op_subi
    op_sub
    @instr_body.gsub!(/i = MKOP_ABC\(OP_SEND.*/, "")
  end

  def op_addi
    op_add
    @instr_body.gsub!(/i = MKOP_ABC\(OP_SEND.*/, "")
  end

  def op_mul
    fix_lsend_2arg("*")
  end

  def op_div
    fix_lsend_2arg("/")
  end

  def op_enter
    ax = @instr.GETARG_Ax
    m1 = (ax>>18)&0x1f
    o  = (ax>>13)&0x1f
    r  = (ax>>12)&0x1
    m2 = (ax>>7)&0x1f

    len = m1 + o + r + m2
    # jumps
    @instr_body.gsub!(/if \(o == 0\)([^;]+;)\s*else([^;]+;)/m) do
      if o == 0
        $1
      else
        $2
      end
    end
    @instr_body.gsub!("pc++", "goto #{label(@line_number+1)}")
    @instr_body.gsub!("pc += argc - m1 - m2 + 1;") do
      str = "switch(argc) {\n"
      # TODO must raise error if too little arguments?
      ((m1+m2)..len-1).each do |i|
        str += "  case #{i}: goto #{label(@line_number+i-m1-m2+1)};\n"
      end
      str += "}\n"
      str
    end
    @instr_body.gsub!("pc += o + 1;", "goto #{label(@line_number+o+1)};")
    @instr_body.gsub!("JUMP;", "")
  end

  def op_jmp
    @instr_body = "goto #{label(@line_number + @instr.GETARG_sBx)};"
  end

  def op_jmpif
    tmp = "pc += GETARG_sBx(i);"
    @instr_body.gsub!(/#{Regexp.escape(tmp)}\s*JUMP;/,
      "goto #{label(@line_number + @instr.GETARG_sBx)};")
  end

  def op_onerr
    @instr_body.gsub!("rescue_label(GETARG_sBx(i))",
      label(@line_number + @instr.GETARG_sBx))
    #tmp = "pc += GETARG_sBx(i);"
    #@instr_body.gsub!(/#{Regexp.escape(tmp)}\s*JUMP;/,
    #  "goto #{label(@line_number + @instr.GETARG_sBx)};")
  end

  def op_jmpnot
    op_jmpif
  end
end
