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
