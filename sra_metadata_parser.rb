# -*- coding: utf-8 -*-
  
require "nokogiri"
require "time"

module SRAMetadataParser  
  class Submission
    def initialize(id, xml)
      @submission = Nokogiri::XML(open(xml)).css("SUBMISSION").select{|n| n.attr("accession") == id }.first
      raise NameError, "submission id not found" unless @submission
    end
    
    def alias
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
      if date =~ /^\d/
        Time.parse(date)
      end
    end
  
    def all
      { submission_comment: self.submission_comment,
        center_name: self.center_name,
        lab_name: self.lab_name,
        submission_date: self.submission_date,
        alias: self.alias }
    end
  end
  
  class Study
    def initialize(id, xml)
      @study = Nokogiri::XML(open(xml)).css("STUDY").select{|n| n.attr("accession") == id }.first
      raise NameError, "study id not found" unless @study
    end
    
    def alias
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
        { label: node.css("LABEL").inner_text,
          url: node.css("URL").inner_text }
      end
    end
    
    def entrez_link
      @study.css("ENTREZ_LINK").map do |node|
        { db: node.css("DB").inner_text,
          id: node.css("ID").inner_text }
      end
    end
    
    def related_link
      @study.css("RELATED_LINK").map do |node|
        { db: node.css("DB").inner_text,
          id: node.css("ID").inner_text,
          label: node.css("LABEL").inner_text }
      end
    end
    
    def all
      { alias: self.alias,
        center_name: self.center_name,
        center_project_name: self.center_project_name,
        study_title: self.study_title,
        study_type: self.study_type,
        study_abstract: self.study_abstract,
        study_description: self.study_description,
        url_link: self.url_link,
        entrez_link: self.entrez_link,
        related_link: self.related_link }
    end
  end
  
  class Experiment
    def initialize(id, xml)
      @exp = Nokogiri::XML(open(xml)).css("EXPERIMENT").select{|n| n.attr("accession") == id }.first
      raise NameError, "experiment id not found" unless @exp
    end
    
    # EXPERIMENT DETAIL
    def alias
      @exp.attr("alias").to_s
    end
    
    def center_name
      @exp.attr("center_name").to_s
    end
    
    def title
      @exp.css("TITLE").inner_text
    end
    
    def study_accession
      @exp.css("STUDY_REF").attr("accession").to_s
    end
    
    def study_refname
      @exp.css("STUDY_REF").attr("refname").to_s
    end
    
    def design_description
      @exp.css("DESIGN_DESCRIPTION").inner_text
    end
    
    def sample_accession
      @exp.css("SAMPLE_DESCRIPTOR").first.attr("accession").to_s
    end
    
    def sample_refname
      @exp.css("SAMPLE_DESCRIPTOR").first.attr("refname").to_s
    end
    
    def experiment_detail
      { center_name: self.center_name,
        title: self.title,
        study_accession: self.study_accession,
        study_refname: self.study_refname,
        design_description: self.design_description,
        sample_accession: self.sample_accession,
        sample_refname: self.sample_refname }
    end
    
    # LIBRARY DESCRIPTION
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
      @exp.css("LIBRARY_LAYOUT").first.children[1].name
    end
    
    def library_orientation
      @exp.css("LIBRARY_LAYOUT").first.children[1].attr("ORIENTATION").to_s
    end

    def library_nominal_length
      @exp.css("LIBRARY_LAYOUT").first.children[1].attr("NOMINAL_LENGTH").to_s
    end

    def library_nominal_sdev
      @exp.css("LIBRARY_LAYOUT").first.children[1].attr("NOMINAL_SDEV").to_s
    end
    
    def library_construction_protocol
      @exp.css("LIBRARY_CONSTRUCTION_PROTOCOL").inner_text
    end
    
    def library_description
      { library_name: self.library_name,
        library_strategy: self.library_strategy,
        library_source: self.library_source,
        library_selection: self.library_selection,
        library_layout: self.library_layout,
        library_orientation: self.library_orientation,
        library_nominal_length: self.library_nominal_length,
        library_nominal_sdev: self.library_nominal_sdev,
        library_construction_protocol: self.library_construction_protocol }
    end
  
    # PLATFORM
    def platform
      @exp.css("PLATFORM").first.children[1].name
    end
    
    def instrument_model
      @exp.css("INSTRUMENT_MODEL").inner_text
    end
    
    def cycle_sequence
      @exp.css("CYCLE_SEQUENCE").inner_text
    end
    
    def cycle_count
      @exp.css("CYCLE_COUNT").inner_text
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
      { platform: self.platform,
        instrument_model: self.instrument_model,
        cycle_sequence: self.cycle_sequence,
        cycle_count: self.cycle_count,
        flow_sequence: self.flow_sequence,
        flow_count: self.flow_count,
        key_sequence: self.key_sequence }
    end
    
    # PROCESSING
    def base_calls
      { sequence_space: @exp.css("SEQUENCE_SPACE").inner_text,
        base_caller: @exp.css("BASE_CALLER").inner_text }
    end
    
    def quality_scores
      @exp.css("QUALITY_SCORES").map do |node|
        { quality_type: node.attr("qtype").to_s,
          quality_scorer: node.css("QUALITY_SCORER").inner_text,
          number_of_level: node.css("NUMBER_OF_LEVELS").inner_text,
          multiplier: node.css("MULTIPLIER").inner_text }
      end
    end
    
    def processing_information
      { base_calls: self.base_calls,
        quality_scores: self.quality_scores }
    end
      
    # SPOT INFORMATION
    def number_of_reads_per_spot
      @exp.css("NUMBER_OF_READS_PER_SPOT").inner_text
    end
    
    def spot_length
      @exp.css("SPOT_LENGTH").inner_text
    end
    
    def spot_information
      { number_of_reads_per_spot: self.number_of_reads_per_spot,
        spot_length: self.spot_length }
    end
      
    # READ SPEC
    def read_spec
      @exp.css("READ_SPEC").map do |node|
        { read_index: node.css("READ_INDEX").inner_text,
          read_class: node.css("READ_CLASS").inner_text,
          read_type: node.css("READ_TYPE").inner_text,
          base_coord: node.css("BASE_COORD").inner_text }
      end
    end
    
    def all
      { experiment_detail: self.experiment_detail,
        library_description: self.library_description,
        platform_information: self.platform_information,
        spot_information: self.spot_information,
        read_spec: self.read_spec }
    end
  end
  
  class Sample
    def initialize(id, xml)
      @sample = Nokogiri::XML(open(xml)).css("SAMPLE").select{|n| n.attr("accession") == id }.first
      raise NameError, "sample id not found" unless @sample
    end
    
    # SAMPLE DETAIL
    def alias
      @sample.attr("alias").to_s
    end
    
    def title
      @sample.css("TITLE").inner_text
    end
    
    def sample_description
      @sample.css("DESCRIPTION").inner_text
    end
    
    def sample_detail
      { title: self.title,
        sample_description: self.sample_description }
    end
    
    # ORGANISM INFORMATION
    def taxon_id
      @sample.css("TAXON_ID").inner_text
    end
    
    def common_name
      @sample.css("COMMON_NAME").inner_text
    end
    
    def scientific_name
      @sample.css("SCIENTIFIC_NAME").inner_text
    end
    
    def anonymized_name
      @sample.css("ANONYMIZED_NAME").inner_text
    end
    
    def individual_name
      @sample.css("INDIVIDUAL_NAME").inner_text
    end
    
    def organism_information
      { taxon_id: self.taxon_id,
        common_name: self.common_name,
        scientific_name: self.scientific_name,
        anonymized_name: self.anonymized_name,
        individual_name: self.individual_name }
    end
    
    # SAMPLE LINKS
    def url_link
      @sample.css("URL_LINK").map do |node|
        { label: node.css("LABEL").inner_text,
          url: node.css("URL").inner_text }
      end
    end
    
    def entrez_link
      @sample.css("ENTREZ_LINK").map do |node|
        { db: node.css("DB").inner_text,
          id: node.css("ID").inner_text }
      end
    end
    
    def sample_links
      { url_link: self.url_link,
        entrez_link: self.entrez_link }
    end
    
    def all
      { sample_detail: self.sample_detail,
        organism_information: self.organism_information,
        sample_links: self.sample_links }
    end
  end
  
  class Run
    def initialize(id, xml)
      @run = Nokogiri::XML(open(xml)).css("RUN").select{|n| n.attr("accession").to_s == id }.first
      raise NameError, "run id not found" unless @run
    end
    
    # RUN DETAIL
    def alias
      @run.attr("alias").to_s
    end
    
    def center_name
      @run.attr("center_name").to_s
    end
    
    def run_date
      date = @run.attr("run_date").to_s
      if date =~ /^\d/ && !date.empty?
        Time.parse(date)
      end
    end
    
    def instrument_name
      @run.attr("instrument_name").to_s
    end
    
    def total_data_blocks
      @run.attr("total_data_blocks").to_s
    end
      
    def run_center
      @run.attr("run_center").to_s
    end
    
    def run_detail
      { alias: self.alias,
        center_name: self.center_name,
        run_date: self.run_date,
        instrument_name: self.instrument_name,
        total_data_blocks: self.total_data_blocks,
        run_center: self.run_center }
    end
    
    # PIPELINE
    def pipeline
      @run.css("PIPE_SECTION").map do |node|
        { section_name: node.attr("secrion_name").to_s,
          step_index: node.css("STEP_INDEX").inner_text,
          prev_step_index: node.css("PREV_STEP_INDEX").inner_text,
          program: node.css("PROGRAM").inner_text,
          version: node.css("VERSION").inner_text }
      end
    end
    
    # SPOT INFORMATION
    def number_of_reads_per_spot
      @run.css("NUMBER_OF_READS_PER_SPOT").inner_text
    end
    
    def spot_length
      @run.css("SPOT_LENGTH").inner_text
    end
    
    def read_spec
      @run.css("READ_SPEC").map do |node|
        { read_index: node.css("READ_INDEX").inner_text,
          read_class: node.css("READ_CLASS").inner_text,
          read_type: node.css("READ_TYPE").inner_text,
          base_coord: node.css("BASE_COORD").inner_text }
      end
    end
    
    def spot_information
      { number_of_reads_per_spot: self.number_of_reads_per_spot,
        spot_length: self.spot_length,
        read_spec: self.read_spec }
    end
    
    # RUN ATTRIBUTES
    def run_attr
      @run.css("RUN_ATTRIBUTE").map do |node|
        { tag: node.css("TAG").inner_text,
          value: node.css("VALUE").inner_text }
      end
    end
    
    def all
      { run_detail: self.run_detail,
        pipeline: self.pipeline,
        spot_information: self.spot_information,
        run_attr: self.run_attr }
    end
  end
end
