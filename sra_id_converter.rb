# -*- coding:utf-8 -*-
# be sure to check if SRA_Accession file is up-to-date.

# will be changed to look for the file with yaml configuration
metadata_dir = "/Volumes/Macintosh HD 2/sra_metadata/latest"
sra_accession = "#{metadata_dir}/SRA_Accessions"
sra_run_members = "#{metadata_dir}/SRA_Run_Members"

class SubmissionID
  def initialize(sub_id)
    @submission = sub_id
    @accessions = open().readlines.select{|l| l.include?(sub_id) }.map{|l| l.split("\t").first }
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
    { :submission => @sub_id,
      :study => self.study,
      :experiment => self.experiment,
      :sample => self.sample,
      :run => self.run }
  end
end

class StudyID
  def initialize(study_id)
    @study = study_id
    @accession = open().readlines.select{|id| l =~ /^#{id}/ }.first
  end
  attr_reader :study
  
  def submission
    @accsession.split("\t")[1]
  end
  
  
end

class ExperimentID
end

class SampleID
end

class RunID
end
