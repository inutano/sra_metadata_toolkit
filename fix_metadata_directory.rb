# -*- coding: utf-8 -*-

require "fileutils"

if __FILE__ == $0
  origin = ARGV.first
  exit 1 unless File.exist?(origin) or File.directory?(origin)
  origin_dirs = Dir.entries(origin).select{|f| f =~ /^.RA\d{6}$/ }
  prefix = origin_dirs.map{|f| f.slice(0,6) }.uniq
  prefix.each do |p|
    moveto = "./#{origin}/" + p
    tobemoved = origin_dirs.select{|f| f =~ /^#{p}/ }.map{|f| "./#{origin}/" + f }
    FileUtils.mkdir(moveto)
    FileUtils.mv(tobemoved,moveto)
  end
end
