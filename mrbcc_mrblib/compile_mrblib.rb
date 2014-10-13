require 'fileutils'

tmp_fn = File.expand_path("../../tmp_mrblib.rb", __FILE__)
File.open(tmp_fn, "w") do |outf|
  Dir[File.expand_path("../../mruby/mrblib/*.rb", __FILE__)].each do |fn|
    outf.write(File.read(fn))
  end
end

%x[cd ../ && ./compile tmp_mrblib.rb]

out_fn = File.expand_path("../../tmp_mrblib.so", __FILE__)
lib_fn = File.expand_path("../mrblib.so", __FILE__)
if File.exists?(out_fn)
  FileUtils.mv(out_fn, lib_fn)
else
  puts "mrblib compile failed."
end
FileUtils.rm(tmp_fn, :force => true)
