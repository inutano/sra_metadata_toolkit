# -*- coding: utf-8 -*-

class FastQCParser
  def initialize(fastqc_data_path)
    @txt = open(fastqc_data_path).read
    @txt =~ /(>>Basic Statistics.*?)>>END_MODULE/m
    @basic_stat = $1
  end
  
  def basic_statistics
    @txt =~ /(>>Basic Statistics.*?)>>END_MODULE/m
    $1
  end
  
  def filename
    @basic_stat =~ /Filename\t(.+?)\t/m
    $1
  end
  
  def file_type
    @basic_stat =~ /File type\t(.+?)\t/m
    $1
  end
  
  def encoding
    @basic_stat =~ /Encoding\t(.+?)\t/m
    $1
  end
  
  def total_sequences
    @basic_stat =~ /Total Sequences\t(.+?)\t/m
    $1.to_i
  end
  
  def filtered_sequences
    @basic_stat =~ /Filtered Sequences\t(.+?)\t/m
    $1.to_i
  end
  
  def sequence_length
    @basic_stat =~ /Sequence length\t(.+?)\t/m
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
    @basic_stat =~ /\%GC\t(.+?)\t/m
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
    v = per_base.map{|c| c[1].to_f }
    v.reduce(:+) / v.size
  end
  
  def normalized_phred_score
    per_base = self.per_base_sequence_quality
    per_base_median = per_base.map{|c| c[2].to_f }
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
    v = per_base.map{|c| c[1].to_f }
    v.reduce(:+) / v.size
  end
  
  def sequence_length_distribution
    # returns 2d array
    # column: length, count
    @txt =~ /(>>Sequence Length Distribution.+?)>>END_MODULE/m
    base = $1
    mline = base.split("\n")
    mline.select{|l| l =~ /^\d/ }.map{|c| c.split("\t") }
  end
  
  def mean_sequence_length
    distribution = self.sequence_length_distribution
    sum = distribution.map do |length_count|
      length = length_count[0]
      count = length_count[1].to_f
      if length =~ /\d-\d/
        f = length.sub(/-\d+$/,"").to_f
        b = length.sub(/^\d+-/,"").to_f
        mean = (f + b) / 2 + 1
        mean * count
      else
        length.to_i * count
      end
    end
    sum.reduce(:+).to_f / self.total_sequences
  end
  
  def median_sequence_length
    distribution = self.sequence_length_distribution
    array = distribution.map do |length_count|
      length = length_count[0]
      count = length_count[1].to_i
      if length =~ /\d-\d/
        f = length.sub(/-\d+$/,"").to_i
        b = length.sub(/^\d+-/,"").to_i
        mean = (f + b) / 2
        [mean] * count
      else
        [length.to_i] * count
      end
    end
    sorted = array.flatten.sort
    quot = sorted.size / 2
    if !sorted.size.even?
      sorted[quot]
    else
      f = sorted[quot]
      b = sorted[quot - 1]
      (f + b) / 2
    end
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
  #file = "/Users/inutano/project/statistics_sra/fastqc_data/SRR515/SRR515734/SRR515734_1_fastqc/fastqc_data.txt"
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
  
  ap "total count on read length distribution"
  ap f.sequence_length_distribution.map{|n| n[1].to_i }.reduce(:+)
  
  ap "average sequence length"
  ap f.mean_sequence_length
  
  ap "median sequence length"
  ap f.median_sequence_length
end
