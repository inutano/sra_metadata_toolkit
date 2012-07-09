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
    SRAMetadataParser::Submission.new(origin_id, xml) if File.exist?(xml)

  when "P"
    xml = prefix + ".study.xml"
    SRAMetadataParser::Study.new(origin_id, xml) if File.exist?(xml)

  when "X"
    xml = prefix + ".experiment.xml"
    SRAMetadataParser::Experiment.new(origin_id, xml) if File.exist?(xml)

  when "S"
    xml = prefix + ".sample.xml"
    SRAMetadataParser::Sample.new(origin_id, xml) if File.exist?(xml)

  when "R"
    xml = prefix + ".run.xml"
    SRAMetadataParser::Run.new(origin_id, xml) if File.exist?(xml)
  end
end

module MethodValidator
  def method_valid?(method)
    parent_class = self.class.superclass
    valid_method = self.methods - parent_class.methods
    valid_method.include?(method)
  end

  def valid_methods
    parent_class = self.class.superclass
    self.methods - parent_class.methods
  end
end

class FastQCParser
  include MethodValidator
end

class SRAMetadataParser
  include MethodValidator
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

get %r{/fastqc/json/((S|E|D)RR\d{6}(|_1|_2))\.(\w+)$} do |filename, db, read, method_str|
  id = filename.slice(0,9)
  id_head = id.slice(0,6)
  result_path = "./fastqc/#{id_head}/#{id}/#{filename}_fastqc/fastqc_data.txt"
  if File.exist?(result_path)
    fparser = FastQCParser.new(result_path)
    method = method_str.intern
    if fparser.method_valid?(method)
      result = fparser.send(method)
      JSON.dump(result)
    elsif method == :methods
      result = fparser.valid_methods
      JSON.dump(result)
    end
  else
    "no result"
  end
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

get %r{/metadata/((S|E|D)R(.)\d{6})\.(\w+)$} do |origin, db, id_type, method_str|
  converter = converter_gen(origin, id_type)
  metadata_parser = get_parser(converter)
  if metadata_parser
    method = method_str.intern
    if metadata_parser.method_valid?(method)
      result = metadata_parser.send(method)
      result = [result] unless result.class == (Hash or Array)
      JSON.dump(result)
    elsif method == :methods
      result = metadata_parser.valid_methods
      JSON.dump(result)
    end
  else
    "metadata file not found."
  end
end
