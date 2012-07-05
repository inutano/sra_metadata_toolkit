# -*- coding: utf-8 -*-

require "./sra_id_converter"
require "./sra_metadata_parser"
require "./fastqc_result_parser"
require "sinatra"
require "json"

def converter_gen(origin, id_type)
  case id_type
  when "A"
    SRAIDConverter::SubmissionID.new(origin)

  when "P"
    SRAIDConverter::StudyID.new(origin)

  when "X"
    SRAIDConverter::ExperimentID.new(origin)
  
  when "S"
    SRAIDConverter::SampleID.new(origin)

  when "R"
    SRAIDConverter::RunID.new(origin)
  end
end

def get_parser(converter)
  cur_dir = File.expand_path(File.dirname(__FILE__))
  sub_id = converter.submission.first
  prefix = "#{cur_dir}/latest/#{sub_id.slice(0,6)}/#{sub_id}/#{sub_id}"
  origin_id = converter.origin
  origin_id =~ /^\wR(?<type>\w)/
  case $~[:type]
  when "A"
    xml = prefix + ".submission.xml"
    SubmissionParser.new(origin_id, xml) if File.exist?(xml)

  when "P"
    xml = prefix + ".study.xml"
    StudyParser.new(origin_id, xml) if File.exist?(xml)

  when "X"
    xml = prefix + ".experiment.xml"
    ExperimentParser.new(origin_id, xml) if File.exist?(xml)

  when "S"
    xml = prefix + ".sample.xml"
    SampleParser.new(origin_id, xml) if File.exist?(xml)

  when "R"
    xml = prefix + ".run.xml"
    RunParser.new(origin_id, xml) if File.exist?(xml)
  end
end

# INITIALIZE MODULE SRAIDConverter
cur_dir = File.expand_path(File.dirname(__FILE__))
sra_accessions_path = "#{cur_dir}/SRA_Accessions"
sra_run_members_path = "#{cur_dir}/SRA_Run_Members"
sra_publications_path = "#{cur_dir}/SRA_Publications"
SRAIDConverter.load_table(sra_accessions_path, sra_run_members_path, sra_publications_path)

# ROUTING
get "/" do
  "SRA METADATA TOOLKIT"
end

get %r{/readfile/((S|E|D)RR\d{6})$} do |id, db|
  id_head = id.slice(0,6)
  id_dir = "./fastqc/#{id_head}/#{id}"
  fastqc_files = Dir.entries(id_dir).select{|f| f =~ /_fastqc$/ }
  read_files = fastqc_files.map{|f| f.gsub(/_fastqc$/,"")}
  JSON.dump(read_files)
end

get %r{/fastqc/json/((S|E|D)RR\d{6}(|_1|_2))$} do |filename, db, read|
  id = filename.slice(0,9)
  id_head = id.slice(0,6)
  result_path = "./fastqc/#{id_head}/#{id}/#{filename}_fastqc/fastqc_data.txt"
  f = FastQCparser.new(result_path)
  JSON.dump(f.all)
end

get %r{/idconvert/((S|E|D)R(.)\d{6})\.to_(.+)$} do |origin, db, id_type, dest|
  converter = converter_gen(origin, id_type)
  result = case dest
           when "submission"
             converter.submission
           
           when "study"
             converter.study

           when "experiment"
             converter.experiment

           when "sample"
             converter.sample

           when "run"
             converter.run
             
           when "pmid"
             converter.pmid
             
           when "all"
             converter.all           
           end
  JSON.dump(result)
end

get %r{/metadata/((S|E|D)R(.)\d{6})\.(\w+)$} do |origin, db, id_type, method|
  converter = converter_gen(origin, id_type)
  metadata_parser = get_parser(converter)
  if metadata_parser
    parent_methods = metadata_parser.class.superclass.methods
    valid_methods = metadata_parser.methods - parent_methods
    method_sym = method.intern
    if valid_methods.include?(method_sym)
      result = metadata_parser.send(method_sym)
      result = [result] unless result.class == (Hash or Array)
      JSON.dump(result)
    elsif method_sym == :methods
      JSON.dump(valid_methods)
    else
      "invalid method"
    end
  else
    "metadata file not found."
  end
end
