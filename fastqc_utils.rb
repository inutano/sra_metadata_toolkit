# -*- coding: utf-8 -*-

module FastQC
  class FastQCParser
    def initialize(fpath)
      txt = open(fpath).read
      @obj = parse(txt)
      @base = self.basic_statistics
    end
    
    def parse(txt)
      modules = txt.split(">>END_MODULE\n")
      modules.map do |node|
        lines = node.split("\n")
        rm_header = lines.map do |line|
          if line !~ /^\#/ || line =~ /^#Total Duplicate Percentage/
            line.split("\t")
          end
        end
        rm_header.compact
      end
    end
    
    def basic_statistics
      Hash[*@obj.select{|a| a.first.first == ">>Basic Statistics" }.flatten]
    end
    
    def filename
      @base["Filename"]
    end
    
    def file_type
      @base["File type"]
    end
    
    def encoding
      @base["Encoding"]
    end
    
    def total_sequences
      @base["Total Sequences"].to_i
    end
    
    def filtered_sequences
      @base["Filtered Sequences"].to_i
    end
    
    def sequence_length
      @base["Sequence length"]
    end
    
    def min_length
      l = @base["Sequence length"]
      if l =~ /\d-\d/
        l.sub(/-\d+$/,"").to_i
      else
        l.to_i
      end
    end
    
    def max_length
      l = @base["Sequence length"]
      if l =~ /\d-\d/
        l.sub(/^\d+-/,"").to_i
      else
        l.to_i
      end
    end
    
    def percent_gc
      @base["%GC"].to_i
    end
    
    def per_base_sequence_quality
      node = @obj.select{|a| a.first.first == ">>Per base sequence quality" }
      node.first.select{|n| n.first != ">>Per base sequence quality" }
    end
    
    def total_mean_sequence_qual
      per_base = self.per_base_sequence_quality
      v = per_base.map{|c| c[1].to_f }
      v.reduce(:+) / v.size
    end
    
    def normalized_phred_score
      per_base = self.per_base_sequence_quality
      v = per_base.map{|c| c[2].to_f }
      v.reduce(:+) / v.size
    end
    
    def per_sequence_quality_scores
      node = @obj.select{|a| a.first.first == ">>Per sequence quality scores" }
      node.first.select{|n| n.first != ">>Per sequence quality scores" }
    end
    
    def per_base_sequence_content
      node = @obj.select{|a| a.first.first == ">>Per base sequence content" }
      node.first.select{|n| n.first != ">>Per base sequence content" }
    end
    
    def per_base_gc_content
      node = @obj.select{|a| a.first.first == ">>Per base GC content" }
      node.first.select{|n| n.first != ">>Per base GC content" }
    end
    
    def per_sequence_gc_content
      node = @obj.select{|a| a.first.first == ">>Per sequence GC content" }
      node.first.select{|n| n.first != ">>Per sequence GC content" }
    end
    
    def per_base_n_content
      node = @obj.select{|a| a.first.first == ">>Per base N content" }
      node.first.select{|n| n.first != ">>Per base N content" }
    end
    
    def total_n_content
      per_base = self.per_base_n_content
      v = per_base.map{|c| c[1].to_f }
      v.reduce(:+) / v.size
    end
    
    def sequence_length_distribution
      node = @obj.select{|a| a.first.first == ">>Sequence Length Distribution" }
      node.first.select{|n| n.first != ">>Sequence Length Distribution" }
    end
    
    def mean_sequence_length
      distribution = self.sequence_length_distribution
      sum = distribution.map do |length_count|
        length = length_count[0]
        count = length_count[1].to_f
        if length =~ /\d-\d/
          f = length.sub(/-\d+$/,"").to_i
          b = length.sub(/^\d+-/,"").to_i
          mean = (f + b) / 2
          mean * count
        else
          length.to_i * count
        end
      end
      sum.reduce(:+) / self.total_sequences
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
      node = @obj.select{|a| a.first.first == ">>Sequence Duplication Levels" }
      node.first.select{|n| n.first != ">>Sequence Duplication Levels" && n.first != "\#Total Duplicate Percentage" }
    end
    
    def total_duplicate_percentage
      node = @obj.select{|a| a.first.first == ">>Sequence Duplication Levels" }
      node.first.select{|n| n.first == "\#Total Duplicate Percentage" }.flatten[1].to_f
    end
    
    def overrepresented_sequences
      node = @obj.select{|a| a.first.first == ">>Overrepresented sequences" }
      node.first.select{|n| n.first != ">>Overrepresented sequences" }
    end
    
    def  kmer_content
      node = @obj.select{|a| a.first.first == ">>Kmer Content" }
      node.first.select{|n| n.first != ">>Kmer Content" }
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
        kmer_content: self.kmer_content,
        min_length: self.min_length,
        max_length: self.max_length,
        total_mean_sequence_qual: self.total_mean_sequence_qual,
        normalized_phred_score: self.normalized_phred_score,
        total_n_content: self.total_n_content,
        mean_sequence_length: self.mean_sequence_length,
        median_sequence_length: self.median_sequence_length,
        total_duplicate_percentage: self.total_duplicate_percentage }
    end
  end
end  
  
