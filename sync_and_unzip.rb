# :)

require "rake"

class SeqSpecUtils
  include Rake::DSL
  
  def self.rsync(origin, dest)
    sh "/usr/bin/rsync -avz #{origin} #{dest}"
  end
  
  def initialize(zipped_dir, unzipped_dir)
    @zipped_path = File.expand_path(zipped_dir)
    @unzipped_path = File.expand_path(unzipped_dir)
    @to_be_unzipped = to_be_unzipped
  end
  
  def to_be_unzipped
    zip, unzip = [@zipped_path, @unzipped_path].map do |dirpath|
      sym = dirpath == @zipped_path ? :zipped : :unzipped
      get_files(sym, dirpath).map{|p| p.split("/").last.gsub(".zip","") }
    end
    (zip - unzip)
  end

  def get_files(sym, dir)
    ext = ".zip" if sym == :zipped
    Dir.glob(dir+"/?RR*/?RR*/?RR*_fastqc#{ext}")
  end
  
  def unzip_all
    threads = []
    @to_be_unzipped.each do |fastqc_id|
      th = Thread.new do
        unzip(fastqc_id)
      end
      threads << th
    end
    threads.each do |th|
      th.join
    end
  end
  
  def unzip(fastqc_id)
    origin, dest = [@zipped_path, @unzipped_path].map do |path|
      fastqc_id_to_dir(path, fastqc_id)
    end
    fname = fastqc_id + ".zip"
    sh "cd #{dest} && cp #{origin}/#{fname} . && unzip #{fname} && rm -f #{fname}"
  end
  
  def fastqc_id_to_dir(pdir, fastqc_id)
    id = fastqc_id.gsub(/(|_.)_fastqc$/,"")
    idx = id.slice(0..5)
    File.join(pdir, idx, id)
  end
  
  def create_all_pdir
    list = @to_be_unzipped.map{|id| id.slice(0..5) }.uniq
    list.each do |id|
      create_pdir(id)
    end
  end
  
  def create_pdir(fastqc_id)
    pdir_path = File.join(@unzipped_path, fastqc_id.slice(0..5))
    sh "mkdir #{pdir_path}"
  end
end

if __FILE__ == $0
  src = "/Users/inutano/src/sra"
  zip_path = src + "/fastqc_zip_from_ddbj"
  unzip_path = src + "/fastqc_unzipped"

  origin = "ddbj:backup/fastqc_result/"
  SeqSpecUtils.rsync(origin, zip_path)

  ssu = SeqSpecUtils.new(zip_path, unzip_path)
  ssu.create_all_pdir
  ssu.unzip_all
end
