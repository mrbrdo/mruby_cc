require 'stringio'
require_relative './mrbcc/preparser'
# preparse
rb_filename = File.expand_path('../test/performance_test.rb', __FILE__)
rb_filename_noext = File.basename(rb_filename, ".rb")
Preparser.preparse(rb_filename, "tmp/tmp_out.rb")

# run
durations_separator = 'Durations:'

puts "Running with mruby..."
output = %x[mruby/bin/mruby tmp/tmp_out.rb]
idx = output.index(durations_separator)
perf_mruby = if idx
  eval(output[idx + durations_separator.length, output.length].strip)
end

puts "Compiling with mruby_cc..."
%x[./compile test/performance_test.rb]
puts "Running with mruby_cc..."
output = %x[./runner test/performance_test.so]
idx = output.index(durations_separator)
perf_mruby_cc = if idx
  eval(output[idx + durations_separator.length, output.length].strip)
end

diff = perf_mruby.keys.map do |key|
  perf_data = {
    mruby: perf_mruby[key],
    mruby_cc: perf_mruby_cc[key]
  }
  [key, perf_data]
end
diff = Hash[diff]

diff_percent = diff.each_pair.map do |key, data|
  [key, data[:mruby_cc] / data[:mruby].to_f]
end

diff_percent.sort! { |a,b| b[1] <=> a[1] }

diff_percent.each do |data|
  key = data[0]
  puts key
  puts (data[1] * 100).ceil.to_s + "% mruby: #{perf_mruby[key]}, mruby_cc: #{perf_mruby_cc[key]}"
end
