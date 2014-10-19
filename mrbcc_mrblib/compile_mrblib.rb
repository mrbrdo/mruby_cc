require 'fileutils'

def write_gem_rb_code(outf, name)
  Dir[File.expand_path("../../mruby/mrbgems/mruby-#{name}/mrblib/*.rb", __FILE__)].each do |fn|
    outf.write(File.read(fn))
  end
end

tmp_fn = File.expand_path("../../tmp_mrblib.rb", __FILE__)
File.open(tmp_fn, "w") do |outf|
  Dir[File.expand_path("../../mruby/mrblib/*.rb", __FILE__)].each do |fn|
    outf.write(File.read(fn))
  end

  # mrbgems
  ordered_mrbgems = %w{sprintf print}
  ordered_mrbgems.each { |name| write_gem_rb_code(outf, name) }
  Dir[File.expand_path("../../mruby/build/host/mrbgems/mruby-*", __FILE__)].each do |fn|
    if name = fn[/mruby-([^\/\\\.]+)\z/, 1]
      next if ordered_mrbgems.include?(name)
      puts name
      write_gem_rb_code(outf, name)
    end
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
