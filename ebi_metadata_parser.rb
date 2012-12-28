# -*- coding: utf-8 -*-

require "nokogiri"
require "time"

module ERAMetadataParser
  class Submission
    def initialize(id, xml)
      @nkgr = Nokogiri::XML(xml)
    end
    
    def center_name
      @nkgr.css("SUBMISSION").attribute("center_name").to_s
    end
    
    def submission_date
      date = @nkgr.css("SUBMISSION").attribute("submission_date").to_s
      if date =~ /^\d/
        Time.parse(date)
      end
    end
    
    def alias
      @nkgr.css("SUBMISSION").attribute("alias").to_s
    end
    
    def title
      @nkgr.css("TITLE").inner_text
    end
    
    def xref
      @nkgr.css("SUBMISSION_LINK XREF_LINK").map do |node|
        id = node.css("ID").inner_text
        id_separated = id.split(",")
        id_array = id_separated.map do |id|
          if id.include?("-")
            h = id.slice(0..2)
            f = id.slice(3..8).to_i
            b = id.slice(13..19).to_i
            (f..b).to_a.map{|i| h + "%06d"%i.to_s}
          else
            id
          end
        end
        list = id_array.flatten
        db = node.css("DB").inner_text
        case db
        when "ENA-STUDY"
          { studyid: list }
        when "ENA-SAMPLE"
          { sample: list }
        when "ENA-EXPERIMENT"
          { experiment: list }
        when "ENA-RUN"
          { run: list }
        when "ENA-FASTQ-FILES"
          id
        end
      end
    end
    
    def attribute
      @nkgr.css("SUBMISSION_ATTRIBUTE").map do |node|
        tag = node.css("TAG").inner_text
        case tag
        when "ENA-SPOT-COUNT"
          { spot: node.css("VALUE").inner_text }
        when "ENA-BASE-COUNT"
          { base: node.css("VALUE").inner_text }
        end
      end
    end
    
    def all
      { center_name: self.center_name,
        submission_date: self.submission_date,
        alias: self.alias,
        title: self.title,
        xref: self.xref,
        attribute: self.attribute }
    end
  end
  
  class Study
    def initialize(id, xml)
      @nkgr = Nokogiri::XML(xml)
    end
    
    def 
  end
end
