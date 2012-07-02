# -*- coding: utf-8 -*-

#require "./sra_id_converter"
#require "./sra_metadata_parser"
require "./fastqc_result_parser"
require "sinatra"
require "json"

def obj_gen(query)
  query =~ /^(S|E|D)R(A|P|X|S|R)\d{6}$/
  case $2
  when "A"
    SubmissionID.new(query)

  when "P"
    StudyID.new(query)

  when "X"
    ExperimentID.new(query)

  when "S"
    SampleID.new(query)

  when "R"
    RunID.new(query)
  end
end

def get_parser(id, obj)
  sub_id = obj.submission
  prefix = "#{File.expand_path(File.dirname(__FILE__))}/latest/#{sub_id}/#{sub_id}"
  case obj.class
  when SubmissionID
    SubmissionParser.new(id, prefix + ".submission.xml")

  when StudyID
    StudyParser.new(id, prefix + ".study.xml")

  when ExperimentID
    ExperimentParser.new(id, prefix + ".experiment.xml")

  when SampleID
    SampleParser.new(id, prefix + ".sample.xml")

  when RunID
    RunParser.new(id, prefix + ".run.xml")
  end
end

get "/" do
  "SRA METADATA TOOLKIT"
end

get "/*.to_*" do
  origin = params[:splat][0]
  dest = params[:splat][1]
  obj = obj_gen(origin)
  if obj
    result = case dest
             when "submission"
               obj.submission
             
             when "study"
               obj.study

             when "experiment"
               obj.experiment

             when "sample"
               obj.sample

             when "run"
               obj.run
             end
    if result
      JSON.dump(result)
    else
      "invalid: #{dest}"
    end
  else
    "invalid: #{origin}"
  end
end

get "/*\.*" do
  id = params[:splat][0]
  method = params[:splat][1]
  obj = obj_gen(id)
  metadata_parser = get_parser(id, obj)
  if metadata_parser
    result = metadata_parser.send(method.intern)
    if result
      JSON.dump(result)
    else
      "invalid: #{method}"
    end
  else
    "invalid: #{id}"
  end
end

get %r{/fastqc/((S|E|D)RR\d{6})$} do |id, db|
  id_head = id.slice(0,6)
  id_dir = "./fastqc/#{id_head}/#{id}"
  read_files = Dir.entries(id_dir).select{|f| f =~ /_fastqc$/ }
  read_files
end

get %r{/fastqc/json/((S|E|D)RR\d{6}(_|_1_|_2_)fastqc)$} do |filename, db, read|
  id = filename.slice(0,9)
  id_head = id.slice(0,6)
  result_text_path = "./fastqc/#{id_head}/#{id}/#{filename}/fastqc_data.txt"
  f = FastQCparser.new(result_text_path)
  JSON.dump(f.all)
end
