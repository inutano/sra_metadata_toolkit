# -*- coding: utf-8 -*-
# need SRA_Accession and SRA_Run_Members to be loaded on memory (require for a while to load)
# be sure that SRA_Accession and SRA_Run_Members files are up-to-date.

require "json"

module SRAIDConverter
  SRA_Accessions = []
  SRA_Run_Members = []
  SRA_Publications = {}
  
  def self.load_table(sra_accessions, sra_run_members, sra_publications)
    open(sra_accessions).readlines.each do |l|
      SRA_Accessions << l.chomp.split("\t")
    end
    open(sra_run_members).readlines.each do |l|
      SRA_Run_Members << l.chomp.split("\t")
    end
    pub = open(sra_publications){|f| JSON.load(f) }
    pub["ResultSet"]["Result"].each do |entry|
      SRA_Publications[entry["sra_id"]] ||= []
      SRA_Publications[entry["sra_id"]] << entry["pmid"]
    end
  end
  
  class SubmissionID
    def initialize(sub_id)
      @submission = sub_id
      @accessions = SRA_Accessions.select{|l| l[1] == sub_id }.map{|l| l.first }
    end
    
    def origin
      @submission
    end
    
    def submission
      [@submission]
    end
    
    def study
      @accessions.select{|id| id =~ /^.RP\d{6}/ }.uniq.sort
    end
  
    def experiment
      @accessions.select{|id| id =~ /^.RX\d{6}/ }.uniq.sort
    end
  
    def sample
      @accessions.select{|id| id =~ /^.RS\d{6}/ }.uniq.sort
    end
  
    def run
      @accessions.select{|id| id =~ /^.RR\d{6}/ }.uniq.sort
    end
  
    def pmid
      SRA_Publications[@submission].uniq.sort
    end
  
    def all
      { submission: self.submission,
        study: self.study,
        experiment: self.experiment,
        sample: self.sample,
        run: self.run,
        pmid: self.pmid }
    end
  end

  class StudyID
    def initialize(study_id)
      @study = study_id
      @accessions = SRA_Accessions.select{|l| l.first == study_id }
      @run_members = SRA_Run_Members.select{|l| l[4] == study_id }
    end
    
    def origin
      @study
    end
  
    def submission
      @accessions.map{|l| l[1] }.uniq.sort
    end
    
    def study
      [@study]
    end
  
    def experiment
      @run_members.map{|l| l[2] }.uniq.sort
    end
  
    def sample
      @run_members.map{|l| l[3] }.uniq.sort
    end
  
    def run
      @run_members.map{|l| l[0] }.uniq.sort
    end
  
    def pmid
      SRA_Publications[@submission].uniq.sort
    end
  
    def all
      { submission: self.submission,
        study: self.study,
        experiment: self.experiment,
        sample: self.sample,
        run: self.run,
        pmid: self.pmid }
    end
  end

  class ExperimentID
    def initialize(exp_id)
      @experiment = exp_id
      @accessions = SRA_Accessions.select{|l| l.first == exp_id }
      @run_members = SRA_Run_Members.select{|l| l.include?(exp_id) }
    end
    
    def origin
      @experiment
    end
  
    def submission
      @accessions.map{|l| l[1] }.uniq.sort
    end
    
    def study
      @run_members.map{|l| l[4] }.uniq.sort
    end
    
    def experiment
      [@experiment]
    end
  
    def sample
      @run_members.map{|l| l[3] }.uniq.sort
    end
  
    def run
      @run_members.map{|l| l[0] }.uniq.sort
    end
  
    def pmid
      SRA_Publications[@submission].uniq.sort
    end
  
    def all
      { submission: self.submission,
        study: self.study,
        experiment: self.experiment,
        sample: self.sample,
        run: self.run,
        pmid: self.pmid }
    end
  end

  class SampleID  
    def initialize(sample_id)
      @sample = sample_id
      @accessions = SRA_Accessions.select{|l| l.first == sample_id }
      @run_members = SRA_Run_Members.select{|l| l.include?(sample_id) }
    end
    
    def origin
      @sample
    end
  
    def submission
      @accessions.map{|l| l[1] }.uniq.sort
    end
  
    def study
      @run_members.map{|l| l[4] }.uniq.sort
    end
  
    def experiment
      @run_members.map{|l| l[2] }.uniq.sort
    end
    
    def sample
      [@sample]
    end
  
    def run
      @run_members.map{|l| l[0] }.uniq.sort
    end
  
    def pmid
      SRA_Publications[@submission].uniq.sort
    end
  
    def all
      { submission: self.submission,
        study: self.study,
        experiment: self.experiment,
        sample: self.sample,
        run: self.run,
        pmid: self.pmid }
    end
  end

  class RunID
    def initialize(run_id)
      @run = run_id
      @accessions = SRA_Accessions.select{|l| l.first == run_id }
      @run_members = SRA_Run_Members.select{|l| l[0] == run_id }
    end
    
    def origin
      @run
    end
  
    def submission
      @accessions.map{|l| l[1] }.uniq.sort
    end
  
    def study
      @run_members.map{|l| l[4] }.uniq.sort
    end
  
    def experiment
      @run_members.map{|l| l[2] }.uniq.sort
    end
  
    def sample
      @run_members.map{|l| l[3] }.uniq.sort
    end
    
    def run
      [@run]
    end
  
    def pmid
      SRA_Publications[@submission].uniq.sort
    end
  
    def all
      { submission: self.submission,
        study: self.study,
        experiment: self.experiment,
        sample: self.sample,
        run: self.run,
        pmid: self.pmid }
    end
  end
end

if __FILE__ == $0
  require "ap" # only for test section
  puts "loading tables: #{Time.now}"
  converter = SRAIDConverter.load_table("./SRA_Accessions", "./SRA_Run_Members")
  
  puts "done."
  puts "generating convert object: #{Time.now}"
  n = SRAIDConverter::StudyID.new("ERP000546")
  
  puts "done."
  puts "test: #{Time.now}"
  ap n.all
end
