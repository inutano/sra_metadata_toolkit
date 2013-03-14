# -*- coding: utf-8 -*-

class FastQCParser
  def initialize(fastqc_data_path)
    @txt = open(fastqc_data_path).read
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
    $1
  end
  
  def min_length
    len = self.sequence_length
    if len =~ /\d-\d/
      len.sub(/-\d+$/,"").to_i
    else
      len.to_i
    end
  end

  def max_length
    len = self.sequence_length
    if len =~ /\d-\d/
      len.sub(/^\d+-/,"").to_i
    else
      len.to_i
    end
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
  
  def normalized_phred_score
    per_base = self.per_base_sequence_quality
    per_base_median = per_base.map{|c| c[3].to_f }
    per_base_median.reduce(:+) / per_base_median.length
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
    @txt =~ /(>>Per base GC content.+?)>>END_MODULE/m
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
    v = per_base.map{|c| c[1] }
    v.map{|n| "%0.20f" % n.to_f }.reduce(:+) / v.size
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
  
  def all
    { filename: self.filename,
      file_type: self.file_type,
      encoding: self.encoding,
      total_sequences: self.total_sequences,
      filtered_sequences: self.filtered_sequences,
      sequence_length: self.sequence_length,
      percent_gc: self.percent_gc,
      per_base_sequence_quality: self.per_base_sequence_quality,
      per_sequnce_quality_scores: self.per_sequence_quality_scores,
      per_base_sequence_content: self.per_base_sequence_content,
      per_base_gc_content: self.per_base_gc_content,
      per_sequence_gc_content: self.per_sequence_gc_content,
      per_base_n_content: self.per_base_n_content,
      sequence_length_distribution: self.sequence_length_distribution,
      sequence_duplication_levels: self.sequence_duplication_levels,
      overrepresented_sequences: self.overrepresented_sequences,
      kmer_content: self.kmer_content }
  end
end

if __FILE__ == $0
  require "ap" # for debug
  
  file = "/Volumes/Macintosh HD 2/sra_metadata/fastqc/SRR001/SRR001001/SRR001001_1_fastqc/fastqc_data.txt"
  f = FastQCParser.new(file)
  ap f.all
  
  ap "total mean"
  ap f.total_mean_sequence_qual
  ap "normalized phred"
  ap f.normalized_phred_score
  ap "total n content"
  ap f.total_n_content
  ap "total duplication percentage"
  ap f.total_duplicate_percentage
  
  ap "min length"
  ap f.min_length
  ap "max length"
  ap f.max_length
end
