# -*- coding: utf-8 -*-

require "./sra_id_converter"
require "./sra_metadata_parser"
require "sinatra"
require "json"

def obj_gen(query)
  query =~ /^(S|E|D)R(A|P|X|S|R)\d{6}$/
  case
  when $2 == "A"
    SubmissionID.new(query)

  when $2 == "P"
    StudyID.new(query)

  when $2 == "X"
    ExperimentID.new(query)

  when $2 == "S"
    SampleID.new(query)

  when $2 == "R"
    RunID.new(query)
  end
end

def get_parser(id)
  obj = obj_gen(id)
  submission_id = obj.submission
  f_prefix = "#{File.expand_path(File.dirname(__FILE__))}/latest/#{submission_id}/#{submission_id}"
  obj_class = obj.class
  case
  when obj.class == SubmissionID
    SubmissionParser.new(id, f_prefix + ".submission.xml")

  when obj.class == StudyID
    StudyParser.new(id, f_prefix + ".study.xml")

  when obj.class == ExperimentID
    ExperimentParser.new(id, f_prefix + ".experiment.xml")

  when obj.class == SampleID
    SampleParser.new(id, f_prefix + ".sample.xml")

  when obj.class == RunID
    RunParser.new(id, f_prefix + ".run.xml")
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
    result = case
             when dest == "submission"
               obj.submission

             when dest == "study"
               obj.study

             when dest == "experiment"
               obj.experiment

             when dest == "sample"
               obj.sample

             when dest == "run"
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


get "/*.*" do
  id = params[:splat][0]
  method = params[:splat][1]
  
  xml = get_xml(id)
  metadata_parser = get_parser(id)
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
