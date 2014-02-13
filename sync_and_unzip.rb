# :)
# using Enumerable#lazy, only for Ruby 2.0

require "rake"

class SeqSpecUtils
  include Rake::DSL
  
  def self.rsync(origin, dest)
    sh "/usr/bin/rsync -avz #{origin} #{dest}"
  end
  
  def initialize(zipped_dir, unzipped_dir)
    @zipped_path = File.expand_path(zipped_dir)
    @unzipped_path = File.expand_path(unzipped_dir)
    @unziplist = unziplist
  end
  attr_accessor :unziplist
  
  def unziplist
    # return an array of fastqc_id (DRR000001_1_fastqc, DRR1000001_fastqc, etc.)
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
    threads = @unziplist.lazy.map{|id| unzip_task(id) }
    threads.each_slice(12).each do |group|
      group.each{|t| t.join }
    end
  end
  
  def unzip_task(fastqc_id)
    Thread.new do
      unzip(fastqc_id)
    end
  end
  
  def unzip(fastqc_id)
    origin, dest = [@zipped_path, @unzipped_path].map do |path|
      fastqc_id_to_dir(path, fastqc_id)
    end
    fname = fastqc_id + ".zip"
    sh "cd #{dest} && cp #{origin}/#{fname} . && unzip #{fname} 2> /dev/null && rm -f #{fname}" do |ok, res|
      puts fname if !ok
    end
  end
  
  def create_pdir
    list = @unziplist.map{|fqcid| fastqc_id_to_dir(@unzipped_path, fqcid) }.uniq
    list.each do |path|
      sh "mkdir -p #{path}" if !File.exist?(path)
    end
  end

  def fastqc_id_to_dir(pdir, fastqc_id)
    id = fastqc_id.gsub(/(|_.)_fastqc$/,"")
    idx = id.sub(/...$/,"")
    File.join(pdir, idx, id)
  end
end

if __FILE__ == $0
  src = "~/src/sra"
  zip_path = src + "/fastqc_zip_from_ddbj"
  unzip_path = src + "/fastqc_unzipped"
  
  if ARGV.first == "--sync"
    origin = "ddbj:backup/fastqc_result/"
    SeqSpecUtils.rsync(origin, zip_path)
  end

  ssu = SeqSpecUtils.new(zip_path, unzip_path)
  ssu.create_pdir
  ssu.unzip_all
  puts "\#unzipped: " + ssu.unziplist.size.to_s
end
