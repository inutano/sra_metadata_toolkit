# -*- coding: utf-8 -*-

require "nokogiri"
require "time"

class SubmissionParser
  def initialize(id, xml)
    @nkgr = Nokogiri::XML(open(xml))
    @submission = @nkgr.css("SUBMISSION").select{|n| n.attr("accession") == id }.first
  end
  
  def get_alias
    @submission.attr("alias").to_s
  end

  def submission_comment
    @submission.attr("submission_comment").to_s
  end
  
  def center_name
    @submission.attr("center_name").to_s
  end
  
  def lab_name
    @submission.attr("lab_name").to_s
  end
  
  def submission_date
    date = @submission.attr("submission_date").to_s
    Time.parse(date)
  end

  def all
    { :submission_comment => self.submission_comment,
      :center_name => self.center_name,
      :lab_name => self.lab_name,
      :submission_date => self.submission_date,
      :alias => self.get_alias }
  end
end

class StudyParser
  def initialize(id, xml)
    @nkgr = Nokogiri::XML(open(xml))
    @study = @nkgr.css("STUDY").select{|n| n.attr("accession") == id }.first
  end
  
  def get_alias
    @study.attr("alias").to_s
  end
  
  def center_name
    @study.attr("center_name").to_s
  end
  
  def center_project_name
    @study.css("CENTER_PROJECT_NAME").inner_text
  end
  
  def study_title
    @study.css("STUDY_TITLE").inner_text
  end
  
  def study_type
    @study.css("STUDY_TYPE").attr("existing_study_type").to_s
  end
  
  def study_abstract
    @study.css("STUDY_ABSTRACT").inner_text
  end
  
  def study_description
    @study.css("STUDY_DESCRIPTION").inner_text
  end
  
  def url_link
    @study.css("URL_LINK").map do |node|
      { :label => node.css("LABEL").inner_text,
        :url => node.css("URL").inner_text }
    end
  end
  
  def entrez_link
    @study.css("ENTREZ_LINK").map do |node|
      { :db => node.css("DB").inner_text,
        :id => node.css("ID").inner_text }
    end
  end
  
  def all
    { :alias => self.get_alias,
      :center_name => self.center_name,
      :center_project_name => self.center_project_name,
      :study_title => self.study_title,
      :study_type => self.study_type,
      :study_abstract => self.study_abstract,
      :study_description => self.study_description,
      :url_link => self.url_link,
      :entrez_link => self.entrez_link }
  end
end

class ExperimentParser
  def initialize(id, xml)
    @nkgr = Nokogiri::XML(open(xml))
    @exp = @nkgr.css("EXPERIMENT").select{|n| n.attr("accession") == id }.first
  end
  
  # EXPERIMENT DETAIL
  def get_alias
    @exp.attr("alias").to_s
  end
  
  def center_name
    @exp.attr("center_name").to_s
  end
  
  def experiment_title
    @exp.css("TITLE").inner_text
  end
  
  def design_description
    @exp.css("DESIGN_DESCRIPTION").inner_text
  end
  
  def experiment_detail
    { :title => self.experiment_title,
      :design_description => self.design_description }
  end
  
  # LIBRARY INFORMATION
  def library_name
    @exp.css("LIBRARY_NAME").inner_text
  end
  
  def library_strategy
    @exp.css("LIBRARY_STRATEGY").inner_text
  end
  
  def library_source
    @exp.css("LIBRARY_SOURCE").inner_text
  end
  
  def library_selection
    @exp.css("LIBRARY_SELECTION").inner_text
  end
  
  def library_layout
    @exp.css("LIBRARY_LAYOUT").first.name
  end
  
  def library_construction_protocol
    @exp.css("LIBRARY_CONSTRUCTION_PROTOCOL").inner_text
  end
  
  def library_description
    { :library_name => self.library_name,
      :library_strategy => self.library_strategy,
      :library_source => self.library_source,
      :library_selection => self.library_selection,
      :library_layout => self.library_layout,
      :library_construction_protocol => self.library_construction_protocol }
  end

  # PLATFORM
  def platform
    @exp.css("PLATFORM").first.name
  end
  
  def instrument_model
    @exp.css("INSTRUMENT_MODEL").inner_text
  end
  
  def flow_sequence
    @exp.css("FLOW_SEQUENCE").inner_text
  end
  
  def flow_count
    @exp.css("FLOW_COUNT").inner_text
  end
  
  def key_sequence
    @exp.css("KEY_SEQUENCE").inner_text
  end
  
  def platform_information
    { :platform => self.platform,
      :instrument_model => self.instrument_model,
      :key_sequence => self.key_sequence,
      :flow_count => self.flow_count,
      :flow_sequence => self.flow_sequence }
  end

  # PROCESSING
  def base_calls
    { :sequence_space => @exp.css("SEQUENCE_SPACE").inner_text,
      :base_caller =>   @exp.css("BASE_CALLER").inner_text }
  end
  
  def quality_scores
    @exp.css("QUALITY_SCORES").map do |node|
      { :quality_type => node.attr("qtype").to_s,
        :quality_scorer => node.css("QUALITY_SCORER").inner_text,
        :number_of_level => node.css("NUMBER_OF_LEVELS").inner_text,
        :multiplier => node.css("MULTIPLIER").inner_text }
    end
  end
  
  def processing_information
    { :base_calls => self.base_calls,
      :quality_scores => self.quality_scores }
  end
    
  # SPOT INFORMATION
  def number_of_reads_per_spot
    @exp.css("NUMBER_OF_READS_PER_SPOT").inner_text
  end
  
  def spot_length
    @exp.css("SPOT_LENGTH").inner_text
  end
  
  def spot_information
    { :number_of_reads_per_spot => self.number_of_reads_per_spot,
      :spot_length => self.spot_length }
  end
    
  # READ SPEC
  def read_spec
    @exp.css("READ_SPEC").map do |node|
      { :read_index => node.css("READ_INDEX").inner_text,
        :read_class => node.css("READ_CLASS").inner_text,
        :read_type => node.css("READ_TYPE").inner_text,
        :base_coord => node.css("BASE_COORD").inner_text }
    end
  end
  
  def all
    { :experiment_detail => self.experiment_detail,
      :library_description => self.library_description,
      :platform_information => self.platform_information,
      :spot_information => self.spot_information,
      :read_spec => self.read_spec }
  end
end

require "ap"

if __FILE__ == $0
  dir = "./latest/SRA023921"
  s = SubmissionParser.new("SRA023921", "#{dir}/SRA023921.submission.xml")
#  puts s.all
  
  st = StudyParser.new("SRP003565", "#{dir}/SRA023921.study.xml")
#  puts st.all
  
  ex = ExperimentParser.new("SRX026899", "#{dir}/SRA023921.experiment.xml")
  ap ex.all
end
