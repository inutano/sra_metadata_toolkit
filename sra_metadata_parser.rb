# -*- coding: utf-8 -*-
  
require "nokogiri"
require "time"

module SRAMetadataParser
  module_function
  def id_selector(type, xml, id)
    # return an array of nokogiri objects
    dataset = Nokogiri::XML(open(xml)).css(type)
    case id
    when :all
      dataset
    else
      dataset.select{|n| n.attr("accession") =~ /#{id}/ }
    end
  end
  
  class Submission
    def initialize(xml, id: :all)
      @submissionset = SRAMetadataParser::id_selector("SUBMISSION", xml, id)
      raise NameError, "ID not found" if @submission == []
    end
    
    def parse
      @submissionset.map do |submission|
        { 
          alias:              submission.attr("alias").to_s,
          accession:          submission.attr("accession").to_s,
          submission_comment: submission.attr("submission_comment").to_s,
          center_name:        submission.attr("center_name").to_s,
          lab_name:           submission.attr("lab_name").to_s,
          submission_date:    submission.attr("submission_date").to_s
        }
      end
    end
  end
  
  class Study
    def initialize(xml, id: :all)
      @studyset = SRAMetadataParser::id_selector("STUDY", xml, id)
      raise NameError, "ID not found" if @studyset == []
    end
    
    def parse
      @studyset.map do |study|
        { 
          accession:           study.attr("accession").to_s,
          alias:               study.attr("alias").to_s,
          center_name:         study.attr("center_name").to_s,
          center_project_name: study.css("CENTER_PROJECT_NAME").inner_text,
          study_title:         study.css("STUDY_TITLE").inner_text,
          study_type:          study.css("STUDY_TYPE").attr("existing_study_type").to_s,
          study_abstract:      study.css("STUDY_ABSTRACT").inner_text,
          study_description:   study.css("STUDY_DESCRIPTION").inner_text,
          
          url_link:            study.css("URL_LINK").map{|node|
                                 { label: node.css("LABEL").inner_text,
                                   url:   node.css("URL").inner_text    }},
          
          entrez_link:         study.css("ENTREZ_LINK").map{|node|
                                 { db: node.css("DB").inner_text,
                                   id: node.css("ID").inner_text  }},
          
          related_link:        study.css("RELATED_LINK").map{|node|
                                 { db:    node.css("DB").inner_text,
                                   id:    node.css("ID").inner_text,
                                   label: node.css("LABEL").inner_text }},
        }
      end
    end
  end
  
  class Experiment
    def initialize(xml, id: :all)
      @experimentset = SRAMetadataParser::id_selector("EXPERIMENT", xml, id)
      raise NameError, "ID not found" if @studyset == []
    end
    
    def parse
      @experimentset.map do |experiment|
        { 
          accession:          experiment.attr("accession").to_s,
          alias:              experiment.attr("alias").to_s,
          center_name:        experiment.attr("center_name").to_s,
          title:              experiment.css("TITLE").inner_text,
          study_accession:    experiment.css("STUDY_REF").attr("accession").to_s,
          study_refname:      experiment.css("STUDY_REF").attr("refname").to_s,
          design_description: experiment.css("DESIGN_DESCRIPTION").inner_text,
          sample_accession:   experiment.css("SAMPLE_DESCRIPTOR").first.attr("accession").to_s,
          sample_refname:     experiment.css("SAMPLE_DESCRIPTOR").first.attr("refname").to_s,
          
          library_description:    { library_name:                  experiment.css("LIBRARY_NAME").inner_text,
                                    library_strategy:              experiment.css("LIBRARY_STRATEGY").inner_text,
                                    library_source:                experiment.css("LIBRARY_SOURCE").inner_text,
                                    library_selection:             experiment.css("LIBRARY_SELECTION").inner_text,
                                    library_layout:                experiment.css("LIBRARY_LAYOUT").first.children[1].name,
                                    library_orientation:           experiment.css("LIBRARY_LAYOUT").first.children[1].attr("ORIENTATION").to_s,
                                    library_nominal_length:        experiment.css("LIBRARY_LAYOUT").first.children[1].attr("NOMINAL_LENGTH").to_s,
                                    library_nominal_sdev:          experiment.css("LIBRARY_LAYOUT").first.children[1].attr("NOMINAL_SDEV").to_s,
                                    library_construction_protocol: experiment.css("LIBRARY_CONSTRUCTION_PROTOCOL").inner_text,
                                  },
          
          platform_information:   { platform:         experiment.css("PLATFORM").first.children[1].name,
                                    instrument_model: experiment.css("INSTRUMENT_MODEL").inner_text,
                                    cycle_sequence:   experiment.css("CYCLE_SEQUENCE").inner_text,
                                    cycle_count:      experiment.css("CYCLE_COUNT").inner_text,
                                    flow_sequence:    experiment.css("FLOW_SEQUENCE").inner_text,
                                    flow_count:       experiment.css("FLOW_COUNT").inner_text,
                                    key_sequence:     experiment.css("KEY_SEQUENCE").inner_text,
                                  },
          
          processing_information: { base_calls:     { sequence_space: experiment.css("SEQUENCE_SPACE").inner_text,
                                                      base_caller:    experiment.css("BASE_CALLER").inner_text,
                                                    },
                                    
                                    quality_scores: experiment.css("QUALITY_SCORES").map{|node|
                                                      { quality_type:    node.attr("qtype").to_s,
                                                        quality_scorer:  node.css("QUALITY_SCORER").inner_text,
                                                        number_of_level: node.css("NUMBER_OF_LEVELS").inner_text,
                                                        multiplier:      node.css("MULTIPLIER").inner_text
                                                      }
                                                    },
                                    
                                    pipe_section:   experiment.css("PIPE_SECTION").map{|node|
                                                      { step_index:      node.css("STEP_INDEX").inner_text,
                                                        prev_step_index: node.css("PREV_STEP_INDEX").inner_text,
                                                        program:         node.css("PROGRAM").inner_text,
                                                        version:         node.css("VERSION").inner_text,
                                                      }
                                                    },
                                  },
          
          spot_information:       { number_of_reads_per_spot: experiment.css("NUMBER_OF_READS_PER_SPOT").inner_text,
                                    spot_length:              experiment.css("SPOT_LENGTH").inner_text
                                  },
        
          read_spec:              experiment.css("READ_SPEC").map{|node|
                                    { read_index: node.css("READ_INDEX").inner_text,
                                      read_class: node.css("READ_CLASS").inner_text,
                                      read_type: node.css("READ_TYPE").inner_text,
                                      base_coord: node.css("BASE_COORD").inner_text,
                                    }
                                  }
        }
      end
    end
  end
  
  class Sample
    def initialize(xml, id: :all)
      @sampleset = SRAMetadataParser::id_selector("SAMPLE", xml, id)
      raise NameError, "ID not found" if @sampleset == []
    end
    
    def parse
      @sampleset.map do |sample|
        { 
          accession:          sample.attr("accession").to_s,
          alias:              sample.attr("alias").to_s,
          title:              sample.css("TITLE").inner_text,
          sample_description: sample.css("DESCRIPTION").inner_text,
          
          organism_information: { taxon_id:        sample.css("TAXON_ID").inner_text,
                                  common_name:     sample.css("COMMON_NAME").inner_text,
                                  scientific_name: sample.css("SCIENTIFIC_NAME").inner_text,
                                  anonymized_name: sample.css("ANONYMIZED_NAME").inner_text,
                                  individual_name: sample.css("INDIVIDUAL_NAME").inner_text },
          
          sample_links: { url_link:   sample.css("URL_LINK").map{|node|
                                        { 
                                          label: node.css("LABEL").inner_text,
                                          url:   node.css("URL").inner_text,
                                        }
                                      },
                        
                          entrez_link: sample.css("ENTREZ_LINK").map{|node|
                                         { 
                                           db: node.css("DB").inner_text,
                                           id: node.css("ID").inner_text,
                                         }
                                       },
                        },
        }
      end
    end
  end
  
  class Run
    def initialize(xml, id: :all)
      @runset = SRAMetadataParser::id_selector("RUN", xml, id)
      raise NameError, "ID not found" if @runset == []
    end
    
    def parse
      @runset.map do |run|
        { 
          accession:         run.attr("accession").to_s,
          alias:             run.attr("alias").to_s,
          center_name:       run.attr("center_name").to_s,
          run_center:        run.attr("run_center").to_s,
          run_date:          run.attr("run_date").to_s,
          instrument_name:   run.attr("instrument_name").to_s,
          total_data_blocks: run.attr("total_data_blocks").to_s,
          
          pipeline: run.css("PIPE_SECTION").map{|node|
                      {
                        section_name:    node.attr("section_name").to_s,
                        step_index:      node.css("STEP_INDEX").inner_text,
                        prev_step_index: node.css("PREV_STEP_INDEX").inner_text,
                        program:         node.css("PROGRAM").inner_text,
                        version:         node.css("VERSION").inner_text,
                      }
                    },
          
          spot_information: { 
                              number_of_reads_per_spot: run.css("NUMBER_OF_READS_PER_SPOT").inner_text,
                              spot_length:              run.css("SPOT_LENGTH").inner_text,
                              read_spec:                run.css("READ_SPEC").map{|node|
                                                          { 
                                                            read_index: node.css("READ_INDEX").inner_text,
                                                            read_class: node.css("READ_CLASS").inner_text,
                                                            read_type: node.css("READ_TYPE").inner_text,
                                                            base_coord: node.css("BASE_COORD").inner_text,
                                                          }
                                                        },
                            },
          
          run_attr: run.css("RUN_ATTRIBUTE").map{|node|
            {
              tag:   node.css("TAG").inner_text,
              value: node.css("VALUE").inner_text,
            }
          }
        }
      end
    end
  end
end
