# SRA Metadata toolkit

hope they won't update XML format during I'm writing this.

## SRA Metadata Parser

- parser for  SRA Metadata XML, just for SRA XML ver. 1.3

## SRA Metafata API

- get SRA ID related to request
  - query "submission id for DRR000001" => "DRA000001"
- get full/specified section of the Metadata
  - query "title of DRP000001" => "Whole genome sequencing of Baillus subtilis subsp. natto BEST195"
- get publication information
  - query "DRA000001 published?" => true
  - query "DRA000001 pubmed_id" => "20398357"
- get sequence quality
  - I'll just try.
