# -*- coding:utf-8 -*-
# be sure that SRA_Accession and SRA_Run_Members files are up-to-date.
# two table files should be placed in the same directory as this file.

class SubmissionID
  def initialize(sub_id)
    current_dir = "#{File.expand_path(File.dirname(__FILE__))}"
    sra_accessions = open("#{current_dir}/SRA_Accessions").readlines
    sra_run_members = open("#{current_dir}/SRA_Run_Members").readlines
    
    @submission = sub_id
    @accessions = sra_accessions.select{|l| l.include?(sub_id) }.map{|l| l.split("\t").first }
  end
  attr_reader :submission
  
  def study
    @accessions.select{|id| id =~ /^.RP\d{6}/ }
  end
  
  def experiment
    @accessions.select{|id| id =~ /^.RX\d{6}/ }
  end
  
  def sample
    @accessions.select{|id| id =~ /^.RS\d{6}/ }
  end
  
  def run
    @accessions.select{|id| id =~ /^.RR\d{6}/ }
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
    current_dir = "#{File.expand_path(File.dirname(__FILE__))}"
    sra_accessions = open("#{current_dir}/SRA_Accessions").readlines
    sra_run_members = open("#{current_dir}/SRA_Run_Members").readlines
    
    @study = study_id
    @accessions = sra_accessions.select{|l| l =~ /^#{study_id}/ }.first
    @run_members = sra_run_members.select{|l| l.include?(study_id) }
  end
  attr_reader :study
  
  def submission
    @accessions.split("\t")[1]
  end
  
  def experiment
    @run_members.map{|l| l.split("\t")[2] }.uniq
  end
  
  def sample
    @run_members.map{|l| l.split("\t")[3] }.uniq
  end
  
  def run
    @run_members.map{|l| l.split("\t")[0] }.uniq
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
    current_dir = "#{File.expand_path(File.dirname(__FILE__))}"
    sra_accessions = open("#{current_dir}/SRA_Accessions").readlines
    sra_run_members = open("#{current_dir}/SRA_Run_Members").readlines
    
    @experiment = exp_id
    @accessions = sra_accessions.select{|l| l =~ /^#{exp_id}/ }.first
    @run_members = sra_run_members.select{|l| l.include?(exp_id) }
  end
  attr_reader :experiment
  
  def submission
    @accessions.split("\t")[1]
  end
  
  def study
    @run_members.map{|l| l.split("\t")[4] }.uniq
  end
  
  def sample
    @run_members.map{|l| l.split("\t")[3] }.uniq
  end
  
  def run
    @run_members.map{|l| l.split("\t")[0] }.uniq
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
    current_dir = "#{File.expand_path(File.dirname(__FILE__))}"
    sra_accessions = open("#{current_dir}/SRA_Accessions").readlines
    sra_run_members = open("#{current_dir}/SRA_Run_Members").readlines
    
    @sample = sample_id
    @accessions = sra_accessions.select{|l| l =~ /^#{sample_id}/ }.first
    @run_members = sra_run_members.select{|l| l.include?(sample_id) }
  end
  attr_reader :sample
  
  def submission
    @accessions.split("\t")[1]
  end
  
  def study
    @run_members.map{|l| l.split("\t")[4] }.uniq
  end
  
  def experiment
    @run_members.map{|l| l.split("\t")[2] }.uniq
  end
  
  def run
    @run_members.map{|l| l.split("\t")[0] }.uniq
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
    current_dir = "#{File.expand_path(File.dirname(__FILE__))}"
    sra_accessions = open("#{current_dir}/SRA_Accessions").readlines
    sra_run_members = open("#{current_dir}/SRA_Run_Members").readlines
    
    @run = run_id
    @accessions = sra_accessions.select{|l| l =~ /^#{run_id}/ }.first
    @run_members = sra_run_members.select{|l| l.include?(run_id) }
  end
  attr_reader :run
  
  def submission
    @accessions.split("\t")[1]
  end
  
  def study
    @run_members.map{|l| l.split("\t")[4] }.uniq
  end
  
  def experiment
    @run_members.map{|l| l.split("\t")[2] }.uniq
  end
  
  def sample
    @run_members.map{|l| l.split("\t")[3] }.uniq
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
