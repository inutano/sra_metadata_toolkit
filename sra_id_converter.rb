# -*- coding: utf-8 -*-
# need SRA_Accession and SRA_Run_Members to be loaded on memory (require for a while to load)
# be sure that SRA_Accession and SRA_Run_Members files are up-to-date.

module SRAIDConverter
  SRA_Accessions = []
  SRA_Run_Members = []
  
  def self.load_table(sra_accessions, sra_run_members)
    open(sra_accessions).readlines.each do |l|
      SRA_Accessions << l.chomp.split("\t")
    end
    open(sra_run_members).readlines.each do |l|
      SRA_Run_Members << l.chomp.split("\t")
    end
  end
  
  class SubmissionID
    def initialize(sub_id)
      @submission = sub_id
      @accessions = SRA_Accessions.select{|l| l[1] == sub_id }.map{|l| l.first }
    end
    attr_reader :submission
    
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
  
    def pubmed
    end
  
    def all
      { submission: @submission,
        study: self.study,
        experiment: self.experiment,
        sample: self.sample,
        run: self.run }
    end
  end

  class StudyID
    def initialize(study_id)
      @study = study_id
      @accessions = SRA_Accessions.select{|l| l.first == study_id }.first
      @run_members = SRA_Run_Members.select{|l| l[4] == study_id }
    end
    attr_reader :study
  
    def submission
      @accessions[1]
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
  
    def pubmed
    end
  
    def all
      { submission: self.submission,
        study: @study,
        experiment: self.experiment,
        sample: self.sample,
        run: self.run }
    end
  end

  class ExperimentID
    def initialize(exp_id)
      @experiment = exp_id
      @accessions = SRA_Accessions.select{|l| l =~ /^#{exp_id}/ }.first
      @run_members = SRA_Run_Members.select{|l| l.include?(exp_id) }
    end
    attr_reader :experiment
  
    def submission
      @accessions.split("\t")[1]
    end
  
    def study
      @run_members.map{|l| l.split("\t")[4] }.uniq.sort
    end
  
    def sample
      @run_members.map{|l| l.split("\t")[3] }.uniq.sort
    end
  
    def run
      @run_members.map{|l| l.split("\t")[0] }.uniq.sort
    end
  
    def pubmed
    end
  
    def all
      { submission: self.submission,
        study: self.study,
        experiment: @experiment,
        sample: self.sample,
        run: self.run }
    end
  end

  class SampleID  
    def initialize(sample_id)
      @sample = sample_id
      @accessions = SRA_Accessions.select{|l| l =~ /^#{sample_id}/ }.first
      @run_members = SRA_Run_Members.select{|l| l.include?(sample_id) }
    end
    attr_reader :sample
  
    def submission
      @accessions.split("\t")[1]
    end
  
    def study
      @run_members.map{|l| l.split("\t")[4] }.uniq.sort
    end
  
    def experiment
      @run_members.map{|l| l.split("\t")[2] }.uniq.sort
    end
  
    def run
      @run_members.map{|l| l.split("\t")[0] }.uniq.sort
    end
  
    def pubmed
    end
  
    def all
      { submission: self.submission,
        study: self.study,
        experiment: self.experiment,
        sample: @sample,
        run: self.run }
    end
  end

  class RunID
    def initialize(run_id)
      @run = run_id
      @accessions = SRA_Accessions.select{|l| l.first == run_id }.first
      @run_members = SRA_Run_Members.select{|l| l[0] == run_id }
    end
    attr_reader :run
  
    def submission
      @accessions[1]
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
  
    def pubmed
    end
  
    def all
      { submission: self.submission,
        study: self.study,
        experiment: self.experiment,
        sample: self.sample,
        run: @run }
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
