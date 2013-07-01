#!/home/work/opbin/ruby-193/ruby/bin/ruby


require 'find'


DATADIR = "/home/team/weijun/data"
DC = "/home/team/weijun/svn/production/prod/ci_script/datavc.sh"



d = Dir.entries(DATADIR)
d.delete(".")
d.delete("..")

Dir.chdir(DATADIR)

d.each do |dir|
  s = `#{DC} --upload #{dir}`
  m = "|data_type=s|key=#{s.strip}|deploy_name=data/#{dir}|"
  p m
end
  






#Find.find(ECOMDA) do |path|
#  if not FileTest.directory? path
#    #p "#{DC} --upload #{path[18..-1]}"
#    s = `#{DC} --upload #{path[18..-1]}`
#    m = "|data_type=s|key=#{s.strip}|deploy_name=#{path[25..-1]}|"
#    puts m
#  end
#end
