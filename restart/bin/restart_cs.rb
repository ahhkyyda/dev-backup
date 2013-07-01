#!/home/work/opbin/ruby/bin/ruby
#coding: utf-8

require "date"
require "open3"
require "timeout"
require "yaml"
require "pathname"
require "logger"


include Process


def add_blacklist(host, rule)
  if host == "" or rule == ""
    ERR.error "add_blacklist host:#{host} rule:#{rule} parameters invalid"
    return 1
  end
  rulelist = rule.split
  n = 0
  1.upto(RETRY) do
    rulelist.each do |rule|
      p "#{BLOCKCMD} add -h #{host} -r #{rule}"
      stdout,extcode = exec_block("#{BLOCKCMD} add -h #{host} -r #{rule}")
      ps = stdout.scan("OK!")
      if ps.size != 0
        stdout,extcode = exec_block("#{BLOCKCMD} show -h #{host}")
        ps = stdout.scan("Rule:#{rule}")
        if ps.size != 0
          LOG.info "add blacklist host:#{host} rule:#{rule} success"
          next
        end
      end
    end
    return 0
  end
  return 1
end


def del_blacklist(host, rule)
  if host == "" or rule == ""
    ERR.error "del blacklist host:#{host} rule:#{rule} parameters invalid"
    return 1
  end
  n = 0
  1.upto(RETRY) do
    p "#{BLOCKCMD} del -h #{host} -r #{rule}"
    stdout,extcode = exec_block("#{BLOCKCMD} del -h #{host} -r #{rule}")
    ps = stdout.scan("OK!")
    if ps.size != 0
      stdout,extcode = exec_block("#{BLOCKCMD} show -h #{host}")
      ps = stdout.scan("Rule:#{rule}")
      if ps.size == 0
        LOG.info "del blacklist host:#{host} rule:#{rule} success"
        return 0
      end
    end
  end
  return 1
end


class Reboot 
  def initialize(name,hostlist=[],attr_conf)
    @name = name
    @datalist = attr_conf["datalist"]
    @control = attr_conf["control"]
    @status_check = attr_conf["status_check"]
    @alarm_rule = attr_conf["alarm_rule"]
  end

  def stop()
    if not @control.nil?
      p "@name needn't to restart"
      return 1
    else
      
    end




end




__END__

#err.error "test warning"
#err.fatal "test fatal"
#p get_rootdir
#a = exec_block("nohup sleep 10 &>/dev/null &")
#p DateTime.now.strftime("%Y-%m-%d %H-%M-%S")

#p YAML::ENGINE.yamler
#p yml
#p yml.class 
p get_hostlist "im+retrms+d4+t" 
 
 
 
 
  
