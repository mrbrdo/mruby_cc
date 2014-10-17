# encoding: utf-8
require 'active_support/core_ext'
require 'securerandom'
require_relative './rite_parser'

class OpcodeParser
  attr_reader :name, :irep, :opcodes
  DEBUG_MODE = false
  DEBUG_MODE_VERBOSE = DEBUG_MODE && false
  def initialize(parser, opcodes, name, irep = nil, rep_names = nil)
    @name = name || "met_#{SecureRandom.hex}"
    @irep = irep || parser.irep
    @parser = parser
    @opcodes = opcodes
    @prepend_compiled_ireps = []
    if irep
      @entry_point = false
      @rep_names = rep_names
    else
      @entry_point = true
      @rep_names = {}
      name_reps(@irep, @rep_names)
    end
    @rep_name = @rep_names[@irep]
  end

  def name_reps(rep, reps, start = 1)
    reps[rep] = start.to_s
    start += 1
    rep.reps.each do |child_rep|
      start = name_reps(child_rep, reps, start)
    end
    start
  end

  def label(i)
    @instructions_referenced[i] = true
    "L_#{@name.upcase}_#{i}"
  end

  def c_str_escape(str)
    str.gsub(/[^\w\d ]/m) do |c|
      "\\#{c.ord.to_s(8).rjust(3, '0')}"
    end
  end

  def c_comment_escape(str)
    # very simple for now, could be improved
    str.gsub(/[^\w\d ?_!#,+\.\-]/m) do |c|
      "*"
    end
  end

  def value_from_pool_to_code(val)
    case val
    when Float
      "mrb_float_value(mrb, #{val})"
    when Numeric
      "mrb_fixnum_value(#{val})"
    when String
      "mrb_str_new(mrb, \"#{c_str_escape(val)}\", #{val.size})"
    when Regexp
      # TODO
      raise
    else
      val
    end
  end

  def instructions_to_function(instruction_bodies)
    outio = StringIO.new

    # pool and syms
    if @entry_point
      @rep_names.each_pair do |current_irep, name|
        outio.write("static mrb_value _pool_#{name}[#{current_irep.pool.size}];\n")
        outio.write("static mrb_sym _syms_#{name}[#{current_irep.syms.size}];\n")
      end
    end

    @prepend_compiled_ireps.reverse.each do |str|
      outio.write(str)
      outio.write("\n")
    end

    outio.write(method_prelude)
    # set up pool and syms
    if @entry_point
      tabs = "    "
      pool_size_sum = @rep_names.keys.reduce(0) { |sum, irep| sum + irep.pool.size }
      outio.write("  {\n")
      outio.write("#{tabs}mrb_value _gc_pool_protect = mrb_ary_new_capa(mrb, #{pool_size_sum});\n")
      outio.write("#{tabs}ai = mrb->arena_idx;\n")
      @rep_names.each_pair do |current_irep, rep_name|
        current_irep.syms.each.with_index do |sym, sym_idx|
          outio.write("#{tabs}_syms_#{rep_name}[#{sym_idx}] = mrb_intern(mrb, \"#{c_str_escape(sym)}\", #{sym.length});\n")
          #outio.write("  mrb_gc_arena_restore(mrb, ai);\n") # TODO: can remove this
          # TODO: make syms by name eg. _sym_print, so code can be read.. only for symbols with simple name
        end
        current_irep.pool.each.with_index do |val, pool_idx|
          val = value_from_pool_to_code(val)
          outio.write("#{tabs}_pool_#{rep_name}[#{pool_idx}] = #{val};\n")
          outio.write("#{tabs}mrb_ary_push(mrb, _gc_pool_protect, _pool_#{rep_name}[#{pool_idx}]);\n")
          outio.write("#{tabs}mrb_gc_arena_restore(mrb, ai);\n")
        end
      end
      outio.write("  }\n")
    end

    instruction_bodies.each.with_index do |str, idx|
      outio.write("\n  // #{irep.iseqs[idx]}\n")

      if @instructions_referenced[idx] || OpcodeParser::DEBUG_MODE
        outio.write("  #{label(idx)}:")
      end

      outio.write("\n  ");

      if OpcodeParser::DEBUG_MODE
        outio.write("  printf(\"#{c_str_escape(label(idx))}\\n\"); fflush(stdout);\n")
        str2 = <<-EOF
        printf("X#{label(idx).strip}\\nXstack ptr \%d\\n", mrb->c->stack - mrb->c->stbase);
        printf("Xregs ptr \%d\\n", regs - mrb->c->stack);
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
        "_syms_#{@rep_name}[#{$1}]/*#{c_comment_escape(@irep.syms[$1.to_i])}*/"
      end
      # string literals
      #@instr_body.gsub!(/mrb_str_literal\(mrb, (pool\[[^\]]+\])\)/) do
      #  $1
      #end
      # pool
      @instr_body.gsub!(/pool\[([^\]]+)\]/) do
        "_pool_#{@rep_name}[#{$1}]/*#{c_comment_escape(@irep.pool[$1.to_i].to_s)}*/"
      end
      # raise
      @instr_body.gsub!("goto L_RAISE;", "mrbb_raise(mrb);")

      instruction_bodies[@line_number] = @instr_body

    end
    instructions_to_function(instruction_bodies)
  end

  def method_epilogue
    body = "\n"
    if @entry_point
      # TODO look at OP_STOP?
      body += "  return mrb_nil_value();\n"
    else
      body += "  printf(\"ERROR: Method #{c_str_escape(@name)} did not return.\\n\");\n"
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
    @instr_body.gsub!("goto L_SEND;") do
      "regs[a] = mrb_funcall_with_block(mrb, regs[a], " +
      "mrb_intern_cstr(mrb, \"#{c_str_escape(met_name)}\"), 1, &regs[a+1], mrb_nil_value());"
    end
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

    parser = OpcodeParser.new(@parser, opcodes, met_name, irep.reps[@instr.send(arg_name)], @rep_names)
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

  def op_getcv
    clear_debug_err_pc
  end

  def op_getmcnst
    clear_debug_err_pc
  end

  def op_getconst
    clear_debug_err_pc
  end

  def clear_debug_err_pc
    @instr_body.gsub!("ERR_PC_SET(mrb, pc);", "")
    @instr_body.gsub!("ERR_PC_CLR(mrb);", "")
  end
end
