# extract opcode implementation from mruby source
class MrbOpcodes
  def initialize(mruby_path)
    @opcode_impl = Hash.new
    orig_opcodes_src = "#{mruby_path}/src/vm.c"
    add_opcodes(File.read(orig_opcodes_src))

    # patches for opcodes
    Dir[File.expand_path("../codegen_rb/opcode_*.c", __FILE__)].each do |fn|
      add_opcodes(File.read(fn))
    end
  end

  def opcodes
    @opcode_impl
  end

  def get_opcode_body(str)
    str.gsub!(/\A[^\{]*/, "")
    raise "opcode body weird #{str}" if str[0] != "{"

    count_opencurly = 1
    i = 1
    while count_opencurly > 0 && !i.nil? && i < str.length
      # comments
      i = str.index("\n", i) if str[i, 2] == "//"
      i = str.index("*/", i) if str[i, 2] == "/*"

      if str[i] == "{"
        count_opencurly += 1
      elsif str[i] == "}"
        count_opencurly -= 1
      end
      i += 1
    end

    str.slice(0, i+1)
  end

  def add_opcodes(str)
    ops = str.split("CASE(OP_")
    ops.shift
    ops.each do |op|
      op =~ /\A([^\)]+)\)(.*)/m
      if $1.present?
        @opcode_impl["OP_#{$1}"] = get_opcode_body($2)
      end
    end
  end
end
