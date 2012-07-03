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

def get_parser(origin, converter)
  cur_dir = File.expand_path(File.dirname(__FILE__))
  sub_id = converter.submission
  prefix = "#{cur_dir}/latest/#{sub_id.slice(0,6)}/#{sub_id}/#{sub_id}"
  case converter.class
  when SRAIDConverter::SubmissionID
    xml = prefix + ".submission.xml"
    SubmissionParser.new(origin, xml) if File.exist?(xml)

  when SRAIDConverter::StudyID
    xml = prefix + ".study.xml"
    StudyParser.new(origin, xml) if File.exist?(xml)

  when SRAIDConverter::ExperimentID
    xml = prefix + ".experiment.xml"
    ExperimentParser.new(origin, xml) if File.exist?(xml)

  when SRAIDConverter::SampleID
    xml = prefix + ".sample.xml"
    SampleParser.new(origin, xml) if File.exist?(xml)

  when SRAIDConverter::RunID
    xml = prefix + ".run.xml"
    RunParser.new(origin, xml) if File.exist?(xml)
  end
end


# INITIALIZE MODULE SRAIDConverter
cur_dir = File.expand_path(File.dirname(__FILE__))
sra_accessions_path = "#{cur_dir}/SRA_Accesions"
sra_run_members_path = "#{cur_dir}/SRA_Run_Members"
SRAIDConverter.load_table(sra_accesions_path, sra_run_members_path)


# ROUTING

get "/" do
  "SRA METADATA TOOLKIT"
end

get %r{/fastqc/((S|E|D)RR\d{6})$} do |id, db|
  id_head = id.slice(0,6)
  id_dir = "./fastqc/#{id_head}/#{id}"
  read_files = Dir.entries(id_dir).select{|f| f =~ /_fastqc$/ }
  JSON.dump(read_files)
end

get %r{/fastqc/json/((S|E|D)RR\d\{6\}(_|_1_|_2_)fastqc)$} do |filename, db, read|
  id = filename.slice(0,9)
  id_head = id.slice(0,6)
  result_text_path = "./fastqc/#{id_head}/#{id}/#{filename}/fastqc_data.txt"
  f = FastQCparser.new(result_text_path)
  JSON.dump(f.all)
end

get %r{/idconvert/((S|E|D)R(.)\d\{6\})\.to_(.+)$} do |origin, db, id_type, dest|
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
           end
  JSON.dump(result)  
end

get %r{/metadata/((S|E|D)R(.)\d\{6\})\.(\w+)$} do |origin, db, id_type, method|
  converter = converter_gen(origin, id_type)
  metadata_parser = get_parser(origin, converter)
  if metadata_parser
    result = metagata_parser.send(method.intern)
    JSON.dump(result)
  else
    "metadata file not found."
  end
end
