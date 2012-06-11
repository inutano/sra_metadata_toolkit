# -*- coding: utf-8 -*-

f_arr = open("./acc_v_sub").readlines

def sooto(arr_val_hash)
  arr_val_hash.sort_by{|k,v| v.length}.reverse
end

def sooto_n(arr_val_hash, n)
  arr_val_hash.sort_by{|k,v| v.length}.reverse[0..n]
end

project_has_subs = {}
sub_has_projects = {}
sub_has_exps = {}
sub_has_samples = {}
sub_has_runs = {}

f_arr.each do |l|
  l.chomp =~ /^(.+)\t(.+)$/
  id = $1
  sub = $2
  
  if id =~ /^.RP/
    project_has_subs[id] ||= []
    project_has_subs[id].push(sub)
    
    sub_has_projects[sub] ||= []
    sub_has_projects[sub].push(id)
  
  elsif id =~ /^.RX/
    sub_has_exps[sub] ||= []
    sub_has_exps[sub].push(id)
    
  elsif id =~ /^.RS/
    sub_has_samples[sub] ||= []
    sub_has_samples[sub].push(id)
  
  elsif id =~ /^.RR/
    sub_has_runs[sub] ||= []
    sub_has_runs[sub].push(id)
  end
end

if ARGV.first == "--stdout"
  [project_has_subs, sub_has_projects, sub_has_exps, sub_has_samples, sub_has_runs].each do |set|
    sooto_n(set, 19).each do |i|
      puts "#{i.first} has #{i.last.length}"
    end
    puts "\n"
  end

elsif ARGV.first == "--full"
  open("./project_has_subs","w"){|f| f.puts(sooto(project_has_subs).map{|i| "#{i.first},#{i.last.length}"})}
  open("./sub_has_projects","w"){|f| f.puts(sooto(sub_has_projects).map{|i| "#{i.first},#{i.last.length}"})}
  open("./sub_has_exps","w"){|f| f.puts(sooto(sub_has_exps).map{|i| "#{i.first},#{i.last.length}"})}
  open("./sub_has_samples","w"){|f| f.puts(sooto(sub_has_samples).map{|i| "#{i.first},#{i.last.length}"})}
  open("./sub_has_runs","w"){|f| f.puts(sooto(sub_has_runs).map{|i| "#{i.first},#{i.last.length}"})}
end
