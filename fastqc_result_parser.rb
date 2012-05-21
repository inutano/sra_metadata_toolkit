# -*- coding: utf-8 -*-

class FastQCparser
  def initialize(fastqc_result)
    @txt = open(fastqc_result).read
  end
  
  def basic_statistics
    @txt =~ /(>>Basic Statistics.*?)>>END_MODULE/m
    $1
  end
  
  def filename
    base = self.basic_statistics
    base =~ /Filename\t(.+?)\t/m
    $1
  end
end

if __FILE__ == $0
  require "ap" # for debug
  
  file = "/Volumes/Macintosh HD 4/fastqc/SRR001001/SRR001001_1_fastqc/fastqc_data.txt"
  f = FastQCparser.new(file)
  ap f.filename
end
