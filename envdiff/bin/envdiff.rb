#!/home/work/opbin/ruby/bin/ruby
#coding: utf-8
$: << File.dirname(__FILE__)


require 'json'

require 'function'
require 'myhash'

#require 'profile'


Datafile = "data.json"
Prefix = "/home/work/restart"
Black = ['^block','^\..*']

def envinfo(path)
  info = {}
  flist,dlist = SA.list_file(path)
  flist.each {|file| info[file] = Myhash::fast_md5(file)}
  info
end

def dump_data(obj)
  JSON::dump(obj)
end

def load_data(file)
  JSON::load(open(file).read)
end

def get_valid_path(path,prefix,black)
  new_path = []
  black_path = []
  if FileTest.symlink? prefix
    prefix = Pathname.new(prefix).realpath.to_path
  end
  if FileTest.file? prefix
    return prefix
  end
  prefix += "/" if not prefix.end_with? "/"
  path.each do |file|
    file.gsub! prefix,""
    black.each do |r|
      reg = %r{#{r}}
      if reg.match(file) and not black_path.member? file 
        black_path << file
      elsif not new_path.member? file
        new_path << file 
      end
    end  
  end
  new_path -= black_path
  new_path
end

def get_envinfo(prefix,valid_path)
  info = {}
  if FileTest.symlink? prefix
    prefix = Pathname.new(prefix).realpath.to_path
  end
  if FileTest.file? prefix
    return Myhash::fast_md5 prefix
  end
  Dir.chdir(prefix)
  valid_path.each {|file| info[file] = Myhash::fast_md5(file)}
  info
end




h1 = {"bin/block"=>"e39db081a708a4476395c08a74d442b7d", "bin/common.rb"=>"44630fab4f6830fcf2ea2f1cb4fb7e76", "bin/conf.rb"=>"a78974031f182912972e7f6d00a64455", "bin/cs.conf"=>"88260cff505357879bad68da6db931b5", "bin/data.json"=>"79787314e274354490b960b44e43772d", "bin/envdiff.rb"=>"fcd4c1891e0d7f721b6e6835c4c3ba43", "bin/function.rb"=>"0bedb97b7785dd903315910db9d8ed48", "bin/log.rb"=>"1fd9bee089918c9f0d4eda27077b8e43", "bin/myhash.rb"=>"4464a9f7ccb09e6e2423d797c8b16c35", "bin/op.conf"=>"edb6febdea5857f6ab4cb22c36024a10", "bin/restart_cs.rb"=>"ecb03e5007e58737dc727d2c91b402a8", "bin/test.rb"=>"68566dd0e7c2c773f6b3e5e8a30b6c66", "conf_full.sh"=>"30969b3654cbda169daf64dd4721c952", "log/restart.err"=>"591fc07fe9d0cea3911c1f32d2fe29d1", "log/restart.err.20121121"=>"905b329657ce69fb50b3f0edf7b89561", "log/restart.err.20121204"=>"85df101dccfad0e5d680fadadbb3e0a3", "log/restart.err.20121224"=>"dc855486893e67c533387294cac4b682", "log/restart.log"=>"3a8a93e0d58a5a67d5daebb6abe6d9ee", "log/restart.log.20121120"=>"4012ffba9c2f1a8b6233c37314ee368f", "log/restart.log.20121121"=>"e9553620be97b8818d8336a39d7c91b0", "log/restart.log.20121202"=>"ff5fafcdddda112291b4d6914242f597", "log/restart.log.20121204"=>"bda322bc41991d39138cfd954c9a731b", "log/restart.log.20121205"=>"2eb0393b89d1d888215efea94455912b", "log/restart.log.20121213"=>"1cfbcddf59e34dd58f0275a29193ebe7", "log/restart.log.20121224"=>"e7b7aa19cd152739282bfa6004f98497", "note"=>"1cc07ecb02551ff4aa7e006e1941f32f", "retrbs_func.sh"=>"7173f83d79b1832f72aa0cb1fea3b029", "retrbs_restart.sh"=>"f41af918d377be5efa71e6d66299b7a0", "test.rb"=>"3841d0519014364d97abb0e3819ac618"}


h2 = {"bin/.vim"=>"d8e8fca2dc0f896fd7cb4cb0031ba249", "bin/block"=>"e39b081a708a4476395c08a74d442b7d", "bin/common.rb"=>"44630fab4f6830fcf2ea2f1cb4fb7e76", "bin/conf.rb"=>"a78974031f182912972e7f6d00a64455", "bin/cs.conf"=>"88260cff505357879bad68da6db931b5", "bin/data.json"=>"79787314e274354490b960b44e43772d", "bin/envdiff.rb"=>"fcd4c1891e0d7f721b6e6835c4c3ba43", "bin/function.rb"=>"0bedb97b7785dd903315910db9d8ed48", "bin/log.rb"=>"1fd9bee089918c9f0d4eda27077b8e43", "bin/myhash.rb"=>"4464a9f7ccb09e6e2423d797c8b16c35", "bin/op.conf"=>"edb6febdea5857f6ab4cb22c36024a10", "bin/restart_cs.rb"=>"ecb03e5007e58737dc727d2c91b402a8", "bin/test.rb"=>"68566dd0e7c2c773f6b3e5e8a30b6c66", "conf_full.sh"=>"30969b3654cbda169daf64dd4721c952", "log/restart.err"=>"591fc07fe9d0cea3911c1f32d2fe29d1", "log/restart.err.20121121"=>"905b329657ce69fb50b3f0edf7b89561", "log/restart.err.20121204"=>"85df101dccfad0e5d680fadadbb3e0a3", "log/restart.err.20121224"=>"dc855486893e67c533387294cac4b682", "log/restart.log"=>"3a8a93e0d58a5a67d5daebb6abe6d9ee", "log/restart.log.20121120"=>"4012ffba9c2f1a8b6233c37314ee368f", "log/restart.log.20121121"=>"e9553620be97b8818d8336a39d7c91b0", "log/restart.log.20121202"=>"ff5fafcdddda112291b4d6914242f597", "log/restart.log.20121204"=>"bda322bc41991d39138cfd954c9a731b", "log/restart.log.20121205"=>"2eb0393b89d1d888215efea94455912b", "log/restart.log.20121213"=>"1cfbcddf59e34dd58f0275a29193ebe7", "log/restart.log.20121224"=>"e7b7aa19cd152739282bfa6004f98497", "note"=>"1cc07ecb02551ff4aa7e006e1941f32f", "retrbs_func.sh"=>"7173f83d79b1832f72aa0cb1fea3b029", "retrbs_restart.sh"=>"f41af918d377be5efa71e6d66299ib7a0"}






diff,in1,in2 = SA::hashdiff(h1,h2)





def print_diff(diff, in1, in2)
  p "-"*120
  s = 18
  space = " "*(30-5/2-1)
  s1 = "#{space}hostA#{space} " 
  s2 = "#{space}hostB#{space} "
  printf "|%s|%-60s|\n",s1,s2
  p "-"*120
  if not diff.empty?
    diff.each do |item|
      printf "|\033[33m%-60s\033[0m|\033[33m%-60s\033[0m|\n",item.keys[0],item.keys[0]
    end
  end
  if not in1.empty?
    p "-"*120
    in1.each do |item|
      printf "|\033[36m%-60s\033[0m|\033[36m%-60s\033[0m|\n",item.keys[0],""
    end
  end
  if not in2.empty?
    p "-"*120
    in2.each do |item|
      printf "|\033[35m%-60s\033[0m|\033[35m%-60s\033[0m|\n","",item.keys[0]
    end
  end 
  p "-"*120
end


print_diff(diff,in1,in2)

#result = dump(envinfo("/home/work/restart"))
#f = open(Datafile,"w")
#f.write(result)
#f.close
#pp,dp = SA.list_file("/home/work/restart")
#ppp = get_valid_path(pp,Prefix,Black)
#p get_envinfo(Prefix, ppp)

#diff({:a=>1,:b=>2},{:a=>2,:c=>3})








