mrblib = <<-EOF
#include 'mruby/mrblib/array.rb'
#include 'mruby/mrblib/enum.rb'
#include 'mruby/mrblib/class.rb'
#include 'mruby/mrblib/compar.rb'
#include 'mruby/mrblib/error.rb'
#include 'mruby/mrblib/hash.rb'
#include 'mruby/mrblib/kernel.rb'
#include 'mruby/mrblib/numeric.rb'
#include 'mruby/mrblib/print.rb'
#include 'mruby/mrblib/range.rb'
#include 'mruby/mrblib/string.rb'
#include 'mruby/mrblib/struct.rb'
EOF

test_includes = <<-EOF
#include 'mruby/test/t/argumenterror.rb'
#include 'mruby/test/t/array.rb'
#include 'mruby/test/t/basicobject.rb'
#include 'mruby/test/t/bs_block.rb'
#include 'mruby/test/t/bs_literal.rb'
#include 'mruby/test/t/class.rb'
#include 'mruby/test/t/comparable.rb'
#include 'mruby/test/t/enumerable.rb'
#include 'mruby/test/t/exception.rb'
#include 'mruby/test/t/false.rb'
#include 'mruby/test/t/float.rb'
#include 'mruby/test/t/hash.rb'
#include 'mruby/test/t/indexerror.rb'
#include 'mruby/test/t/integer.rb'
#include 'mruby/test/t/kernel.rb'
#include 'mruby/test/t/literals.rb'
#include 'mruby/test/t/localjumperror.rb'
#include 'mruby/test/t/math.rb'
#include 'mruby/test/t/module.rb'
#include 'mruby/test/t/nameerror.rb'
#include 'mruby/test/t/nil.rb'
#include 'mruby/test/t/nomethoderror.rb'
#include 'mruby/test/t/numeric.rb'
#include 'mruby/test/t/object.rb'
#include 'mruby/test/t/proc.rb'
#include 'mruby/test/t/range.rb'
#include 'mruby/test/t/rangeerror.rb'
#include 'mruby/test/t/regexperror.rb'
#include 'mruby/test/t/runtimeerror.rb'
#include 'mruby/test/t/standarderror.rb'
#include 'mruby/test/t/string.rb'
#include 'mruby/test/t/struct.rb'
#include 'mruby/test/t/symbol.rb'
#include 'mruby/test/t/syntax.rb'
#include 'mruby/test/t/time.rb'
#include 'mruby/test/t/true.rb'
#include 'mruby/test/t/typeerror.rb'
EOF

test_fn = File.expand_path("../test.rb", __FILE__)

results = [0, 0, 0, 0]
test_includes.strip.each_line do |line|
  File.open(test_fn, "w") do |f|
    f.puts(mrblib)
    f.puts("#include 'mruby/test/assert.rb'")
    f.puts(line)
    f.puts("report")
  end
  puts "compiling..."
  %x[ruby mrbcc.rb test.rb > /dev/null 2>&1]
  output = %x[./test]
  line = line.strip.gsub("#include", "").gsub("'", "")
  puts "Test: #{line}"
  puts output
  if output =~ /Total: (\d+)/
    results[0] += $1.to_i
    output =~ /OK: (\d+)/
    results[1] += $1.to_i
    output =~ /KO: (\d+)/
    results[2] += $1.to_i
    output =~ /Crash: (\d+)/
    results[3] += $1.to_i
  end

  puts "----------------------"
  puts "-- combined results --"
  puts "----------------------"
  puts "Total: #{results[0]}"
  puts "OK: #{results[1]}"
  puts "KO: #{results[2]}"
  puts "Crash: #{results[3]}"
end

