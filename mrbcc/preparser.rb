module Preparser
  def self.preparse(infile, outfile)
    f = File.read(infile)
    pre_parsed = StringIO.new
    f.each_line do |line|
      if line =~ /\A#include '([^']+)/
        files = $1
        files = File.expand_path("../#{$1}", infile) unless files.start_with?("/")

        Dir[files].each do |fn|
          pre_parsed << File.read(fn)
        end
      else
        pre_parsed << line
      end
    end

    File.open(outfile, "w") do |f|
      f.write(pre_parsed.string)
    end
  end
end
