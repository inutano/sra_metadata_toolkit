# SRA Metadata toolkit

hope they won't update XML format during I'm writing this.

## Table of Contents

- - - - - -

- 1 What's this
- 2 How to use
  - 2.1 SRA ID Converter
  - 2.2 SRA Metadata parser
  - 2.3 FastQC result
    - 2.3.1 readfile
- 3 Development
  - 3.1 About this project
  - 3.2 License

## 1 What's this

- - - - - -

SRA Metadata toolkit is the  project and the web service to use Metadata of the NGSeq data archived in Sequence 
Read Archive. It allows command-line access to get JSON format data parsed as specified with query. It also 
provides quality summary of each sequence data. Details and updates are [here](http://g86.dbcls.jp/chateautogo).

## 2 How to use

- - - - - -

User's can get a part or whole set of metadata by specifying with query.

### 2.1 SRA ID Converter

convert SRA ID to belonged/related ID(s). JSON format output

`/idconvert/<origin SRA ID>.to_<dest SRA ID type>`

`<origin SRA ID>`

valid SRA ID, three letters prefix and six numbers 
  
`<dest SRA ID type>`

submission, study, experiment, sample, run, pmid, all

example:

    /idconvert/DRA000001.to_study
      => ["DRP000001"]
    /idconvert/DRA000001.to_all
      => {"submission":["DRA000001"],"study":["DRP000001"],"experiment":["DRX000001"],"sample":["DRS000001"],"run":["DRR000001"],"pmid":["20398357"]}

### 2.2 SRA Metadata parser

gives JSON format metadata for specified SRA ID

`/metadata/<origin SRA ID>.<method>`

`<origin SRA ID>`

valid SRA ID, three letters perfix and six numbers
  
`<method>`

method to specify which part of metadata to be given.
use ".methods" to get a list of valid methods.
  
example:

    /metadata/DRA000001.submission_comment
      => ["Bacillus subtilis subsp. natto BEST195 draft sequence, the chromosome and plasmid pBEST195S"]
    /metadata/DRA000001.all
      => {"submission_comment":"Bacillus subtilis subsp. natto BEST195 draft sequence, the chromosome and plasmid pBEST195S","center_name":"KEIO","lab_name":"Bioinformatics Lab.","submission_date":"2009-05-14 14:16:00 UTC","alias":"DRA000001"}
    /metadata/DRA000001.methods
      => ["alias","submission_comment","center_name","lab_name","submission_date","all"]

### 2.3 FastQC result

gives JSON format result of FastQC if available

`/fastqc/<origin sequence run file name>.<method>`

`<origin sequence run file name>`

single sequence run file name, descriminate forward/reverse.
list of run file those belong to run id can be got from "filename" api.
  
`<method>`

method to specify which part of metadata to be given.
use ".methods" to get a list of valid methods.

#### 2.3.1 readfile

A list of readfile

`/readfile/<origin SRA Run ID>`

example:

    /readfile/DRR000001
      => ["DRR000001_1","DRR000001_2","DRR000001"]

### 3 Development

#### 3.1 About this project

The main contributor of this project is Tazro Ohta, and this project is going with only one person. Wow.

#### 3.2 License

All code is shared under the Beer-ware License.
