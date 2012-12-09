require_relative './mrbcc/rite_parser'
require_relative './mrbcc/codegen'
require_relative './mrbcc/mrb_opcodes'
require 'fileutils'

opcodes = MrbOpcodes.new(File.expand_path("../mruby", __FILE__))

# preparse file so we can #include
rb_filename = File.expand_path("../#{ARGV[0]}", __FILE__)
rb_filename_noext = File.basename(rb_filename, ".rb")
f = File.read(rb_filename)
pre_parsed = StringIO.new
f.each_line do |line|
  if line =~ /\A#include '([^']+)/
    pre_parsed << File.read(File.expand_path("../../../#{$1}", __FILE__))
  else
    pre_parsed << line
  end
end

File.open(File.expand_path("../tmp_out.rb", __FILE__), "w") do |f|
  f.write(pre_parsed.string)
end

# compile to .mrb
path = File.expand_path("../", __FILE__)
str = %x[cd "#{path}" && mruby/bin/mrbc tmp_out.rb]

# parse
parser = RiteParser.new(File.expand_path("../tmp_out.mrb", __FILE__))

# create C file
File.open(File.expand_path("../build/c_files/out.c", __FILE__), "w") do |wf|
  wf.write(OpcodeParser.new(parser, opcodes.opcodes, "rb_main", 0).process_irep)
end

# compile C file
puts %x[cd "#{path}/build" && make]

# copy C file
FileUtils.mv("#{path}/build/mrbcc_out", "#{path}/#{rb_filename_noext}")
