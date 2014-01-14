# :)

require "rspec"
require "./sync_and_unzip"

describe SeqSpecUtils do
  before do
    src = "/Users/inutano/src/sra"
    @zip_path = src + "/fastqc_zip_from_ddbj"
    @unzip_path = src + "/fastqc_unzipped"
    @ssu = SeqSpecUtils.new(@zip_path, @unzip_path)
  end
  
  it "compares zip/unzip-ed files to list up IDs to be processed" do
    list = @ssu.to_be_unzipped
    list.sample(10).each do |fastqc_id|
      zip, unzip = [@zip_path, @unzip_path].map do |path|
        @ssu.fastqc_id_to_dir(path, fastqc_id)
      end
      expect(File).to exist(zip+"/#{fastqc_id}.zip")
    end
  end
  
  it "execute rsync" do
    origin = "ddbj:hoge"
    dest = "/Users/inutano"
    SeqSpecUtils.rsync(origin, dest)
    expect(File).to exist("/Users/inutano/hoge")
  end
end
