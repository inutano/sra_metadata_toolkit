# -*- coding: utf-8 -*-

require "active_record"
require "logger"
require "./fastqc_result_parser"
require "./sra_metadata_parser"
require "ap"

class SRAID < ActiveRecord::Base
end

def get_qual_result(runid)
  # RETURN ARRAY OF FASTQCPARSER CLASS OBJECTS
  f_path = "./fastqc/#{runid.slice(0,6)}/#{runid}"
  read_dirs = Dir.entries(f_path).select{|f| f =~ /^.RR\d{6}.+fastqc$/ }
  read_dirs.map do |dir|
    data_txt = "#{f_path}/#{dir}/fastqc_data.txt"
    FastQCparser.new(data_txt)
  end
end

if __FILE__ == $0
  # DB CONNECTION AND LOG SETTING
  ActiveRecord::Base.establish_connection(
    :adapter => "sqlite3",
    :database => "./production.sqlite3"
  )
  ActiveRecord::Base.logger = Logger.new("./database.log")
  
  # INITIALIZE TARGET ID LIST: QUALITY ALREADY CALCURATED
  records = SRAID.where( :status => "done")
  
  # LOADING QUALITY DATA INTO ARRAY
  records_qual = records.map do |record|
    begin
      runid = record.runid
      parser_arr = get_qual_result(runid)
      parser_arr.map do |p|
        { filename: p.filename,
          total_sequences: p.total_sequences,
          sequence_length: p.sequence_length,
          percent_gc: p.percent_gc,
          total_phred: p.total_mean_sequence_qual,
          total_n: p.total_n_content,
          total_dup: p.total_duplicate_percentage }
      end
    rescue => ex
      puts "#{ex.class}: #{ex.message}"
    end
  end
  
  # LOADING METADATA INTO ARRAY
  metadata_run = []
  metadata_sample = []
  metadata_exp = []
  records.each do |record|
    begin
      subid = record.subid
      runid = record.runid
      sampleid = record.sampleid
      expid = record.expid
      xml_head = "./latest/#{subid.slice(0,6)}/#{subid}/#{subid}"
      p_run = RunParser.new(runid, xml_head + ".run.xml")
      p_sample = SampleParser.new(sampleid, xml_head + ".sample.xml")
      p_exp = ExperimentParser.new(expid, xml_head + ".experiment.xml")
      if !subid.empty? && !runid.empty? && !sampleid && !expid
        metadata_run << p_run.all
        metadata_sample << p_sample.all
        metadata_exp << p_exp.all
      end
      
    rescue => ex
      puts "#{ex.class}: #{ex.message}"
    end
  end
    
  # TEST
  ap "records_qual 10"
  ap records_qual[0..9]
  ap "metadata_run 10"
  ap metadata_run[0..9]
  ap "metadata_sample 10"
  ap metadata_sample[0..9]
  ap "metadata_exp 10"
  ap metadata_exp[0..9]
end
