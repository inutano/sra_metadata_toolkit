# :)

module FastqcHandler
  def self.index_dirs(base)
    Dir.glob("#{base}/*")
  end
  
  def self.id_dirs(base)
    Dir.glob("#{base}/*/*")
  end
  
  def self.zip_files(base)
    Dir.glob("#{base}/*/*/*")
  end
  
  def self.unexpected_index_dirs(base)
    self.index_dirs(base).select{|p| self.last_path(p) !~ /^(S|E|D)RR\d{3}(|\d)$/ }
  end
  
  def self.unexpected_id_dirs(base)
    self.id_dirs(base).select{|p| self.last_path(p) !~ /^(S|E|D)RR\d{6}(|\d)$/ }
  end
  
  def self.unexpected_zip_files(base)
    a = self.zip_files(base)
    a.select do |p|
      self.last_path(p) !~ /^(S|E|D)RR\d{6}(|\d)(|_1|_2)_fastqc\.zip$/ or !File.file?(p)
    end
  end
  
  def self.unzip_failed(base)
    a = self.zip_files(base)
    a.select do |p|
      self.last_path(p) !~ /^(S|E|D)RR\d{6}(|\d)(|_1|_2)_fastqc$/ or !File.directory?(p)
    end
  end
  
  private
  def self.last_path(path)
    path.split("/").last
  end
end

if __FILE__ == $0
  base = ARGV.first || "./fastqc_result"
  puts Time.now.to_s + "\tfastqc processing status"
  puts "\#index : " + FastqcHandler.index_dirs(base).size.to_s
  puts "\#id    : " + FastqcHandler.id_dirs(base).size.to_s
  puts "\#zip   : " + FastqcHandler.zip_files(base).size.to_s
  puts "unexpected index dirs: "
  puts FastqcHandler.unexpected_index_dirs(base)
  puts "unexpected id dirs: "
  puts FastqcHandler.unexpected_id_dirs(base)
  if ARGV.include?("--zip")
    puts "unexpected zip files: "
    puts FastqcHandler.unexpected_zip_files(base)
  elsif ARGV.include?("--unzip")
    puts "files unzip failed: "
    puts FastqcHandler.unzip_failed(base)
  end
end
