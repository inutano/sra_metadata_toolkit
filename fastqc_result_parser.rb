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
  
  def file_type
    base = self.basic_statistics
    base =~ /File type\t(.+?)\t/m
    $1
  end
  
  def encoding
    base = self.basic_statistics
    base =~ /Encoding\t(.+?)\t/m
    $1
  end
  
  def total_sequences
    base = self.basic_statistics
    base =~ /Total Sequences\t(.+?)\t/m
    $1.to_i
  end
  
  def filtered_sequences
    base = self.basic_statistics
    base =~ /Filtered Sequences\t(.+?)\t/m
    $1.to_i
  end
  
  def sequence_length
    base = self.basic_statistics
    base =~ /Sequence length\t(.+?)\t/m
    $1.to_i
  end
  
  def percent_gc
    base = self.basic_statistics
    base =~ /\%GC\t(.+?)\t/m
    $1.to_f
  end
  
  def per_base_sequence_quality
    # returns 2d array
    # column: base, mean, median, lower quartile, upper quartile, 10th Percentile, 90th Percentile
    @txt =~ /(>>Per base sequence quality.+?)>>END_MODULE/m
    base = $1
    mline = base.split("\n")
    mline.select{|l| l =~ /^\d/ }.map{|c| c.split("\t") }
  end
  
  def total_mean_sequence_qual
    per_base = self.per_base_sequence_quality
    per_base_mean = per_base.map{|c| c[1].to_f }
    line_num = per_base_mean.length
    per_base_mean.reduce(:+) / line_num
  end
  
  def per_sequence_quality_scores
    # returns 2d array
    # column: quality, count
    @txt =~ /(>>Per sequence quality scores.+?)>>END_MODULE/m
    base = $1
    mline = base.split("\n")
    mline.select{|l| l =~ /^\d/ }.map{|c| c.split("\t") }
  end
  
  def per_base_sequence_content
    # returns 2d array
    # column: base position, % of base G, A, T, and C
    @txt =~ /(>>Per base sequence content.+?)>>END_MODULE/m
    base = $1
    mline = base.split("\n")
    mline.select{|l| l =~ /^\d/ }.map{|c| c.split("\t") }
  end
  
  def per_base_gc_content
    # returns 2d array
    # column: base position, %GC
    @txt =~ /(>>Per Base GC content.+?)>>END_MODULE/m
    base = $1
    mline = base.split("\n")
    mline.select{|l| l =~ /^\d/ }.map{|c| c.split("\t") }    
  end
  
  def per_sequence_gc_content
    # returns 2d array
    # column: GC content, read count
    @txt =~ /(>>Per sequence GC content.+?)>>END_MODULE/m
    base = $1
    mline = base.split("\n")
    mline.select{|l| l =~ /^\d/ }.map{|c| c.split("\t") }
  end
  
  def per_base_n_content
    # returns 2d array
    # column: base, n-count
    @txt =~ /(>>Per base N content.+?)>>END_MODULE/m
    base = $1
    mline = base.split("\n")
    mline.select{|l| l =~ /^\d/ }.map{|c| c.split("\t") }
  end
  
  def total_n_content
    per_base = self.per_base_n_content
    per_base_count = per_base.map{|c| c[1] }
    fixed = per_base_count.map do |num|
      if num =~ /E/
        num =~ /(^.+)E-(.)/
        b = $1.to_f
        nn = $2.to_i
        b * (0.1 ** nn).round(4)
      else
        num.to_f
      end
    end
    fixed.reduce(:+) / fixed.length
  end
  
  def sequence_length_distribution
    # returns 2d array
    # column: length, count
    @txt =~ /(>>Sequence Length Distribution.+?)>>END_MODULE/m
    base = $1
    mline = base.split("\n")
    mline.select{|l| l =~ /^\d/ }.map{|c| c.split("\t") }
  end
  
  def sequence_duplication_levels
    # returns 2d array
    # column: duplication level, relative count
    @txt =~ /(>>Sequence Duplication Levels.+?)>>END_MODULE/m
    base = $1
    mline = base.split("\n")
    mline.select{|l| l =~ /^\d/ }.map{|c| c.split("\t") }
  end
  
  def total_duplicate_percentage
    line = @txt.split("\n").select{|l| l =~ /^.Total Duplicate Percentage/ }.first
    line.split("\t")[1].to_f
  end
  
  def overrepresented_sequences
    # returns 2d array
    # column: sequence, count, %, possible source
    @txt =~ /(>>Overrepresented sequences.+?)>>END_MODULE/m
    base = $1
    mline = base.split("\n")
    mline.select{|l| l =~ /^(A|T|G|C)/ }.map{|c| c.split("\t") }
  end
  
  def kmer_content
    # returns 2d array
    # column: sequence, count, obs/exp overall, obs/exp max, max obs/exp position
    @txt =~ /(>>Kmer Content.+?)>>END_MODULE/m
    base = $1
    mline = base.split("\n")
    mline.select{|l| l =~ /^(A|T|G|C)/ }.map{|c| c.split("\t") }    
  end
end

if __FILE__ == $0
  require "ap" # for debug
  
  file = "/Volumes/Macintosh HD 4/fastqc/SRR001001/SRR001001_1_fastqc/fastqc_data.txt"
  f = FastQCparser.new(file)
  ap f.filename
  ap f.file_type
  ap f.encoding
  ap f.total_sequences
  ap f.sequence_length
  ap f.percent_gc 
  
  ap "total mean"
  ap f.total_mean_sequence_qual
  ap "total n content"
  ap f.total_n_content
  ap "total duplication percentage"
  ap f.total_duplicate_percentage
end
