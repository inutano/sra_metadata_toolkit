# -*- coding: utf-8 -*-

require "active_record"
require "logger"

require "./fastqc_result_parser"
require "./sra_metadata_parser"

require "ap"

class SRAID < ActiveRecord::Base
end

def get_qual_result(runid)
  # return array of FastQCparser class objects inside.
  runid_head = runid.slice(0,6)
  f_path = "./fastqc/#{runid_head}/#{runid}"
  read_dirs = Dir.entries(f_path).delete_if{|f| f =~ /^\./ }
  read_dirs.map do |dir|
    data_txt = "#{f_path}/#{dir}/fastqc_data.txt"
    FastQCparser.new(data_txt)
  end
end

if __FILE__ == $0
  # connection and logging
  ActiveRecord::Base.establish_connection(
    :adapter => "sqlite3",
    :database => "./production.sqlite3"
  )
  ActiveRecord::Base.logger = Logger.new("./database.log")
  
  # target: items already calcurated quality
  records = SRAID.where( :status => "done")
  
  # putting quality data into array
  records_qual_parser = records.map do |record|
    runid = record.runid
    parser_arr = get_qual_result(runid)
    qual_data_arr = parser_arr.map do |parser|
      { filename: parser.filename,
        total_phred: parser.total_mean_sequence_qual,
        total_n: parser.total_n_content,
        total_dup: parser.total_duplicate_percentage }
    end
  end
  
  # putting metadata into array
end
