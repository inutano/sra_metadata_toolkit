# -*- coding: utf-8 -*-

require "fileutils"

if __FILE__ == $0
  input_path = ARGV.first
  exit 1 unless File.exist?(input_path) or File.directory?(input_path)
  origin = File.expand_path(input_path)
  origin_dirs = Dir.entries(origin).select{|f| f =~ /^.RA\d{6}$/ }
  prefix = origin_dirs.map{|f| f.gsub(/...$/,"") }.uniq
  prefix.each do |pfx|
    moveto = File.join(origin, pfx)
    files_matched = origin_dir.select{|f| f.gsub(/\d{3}$/,"") == pfx }
    paths_matched = files_matched.map{|f| File.join(origin, f) }
    FileUtils.mkdir(moveto)
    FileUtils.mv(paths_matched, moveto)
  end
end
