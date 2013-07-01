#coding: utf-8
$: << File.dirname(__FILE__)


require "timeout"
require "pathname"
require "log"
require "conf"

module OP
  include Conf
  include Mylog
  
  def exec_block(cmd,timeout=60)
    begin
      #LOG.info "func:#{__method__} cmd:#{cmd} timeout:#{timeout}"
      status = Timeout::timeout(timeout) {
        out = `#{cmd}`
        if $?.exitstatus != 0
            p "exec error: #{cmd}"
        end
        return [out,$?.exitstatus]
      }
    rescue Timeout::Error #=> ex
      puts "execute command: [#{cmd}] timeout"
      return [nil,2]
    rescue Errno::ENOENT => ex
      puts "err: #{ex}"
      return [nil,1]
    rescue => ex
      p "exec error-> command:#{ex}"
    end
  end
  
  def get_host_by_tag(tag)
    hs,extcode = exec_block("nodes search --tags=#{tag}")
    if extcode != 0 or hs == ""
      ERR.error "nodes tags:#{tag} get host error"
      return nil
    end
    hl = []
    hs.each_line {|line| hl << line.chomp}
    hl
  end

  def get_host_by_lh(qstring)
    hs,extcode = exec_block("lh -h #{qstring}")
    p hs
  end

  
  def exec_remote(host, cmd, timeout=1200)
    if host == "" or cmd == ""
      log::ERR.error "exec_remote host:#{host} cmd:#{cmd} parameters invalid"
      return 1
    end
    #LOG.info "#{CONF['SSH_CMD']} #{CONF['SSH_OPT']} #{host} \"#{cmd}\""
    begin
      exec_block("#{CONF['SSH_CMD']} #{CONF['SSH_OPT']} #{host} \"#{cmd}\"",timeout=timeout)
    rescue => ex
      ERR.fatal "exec remote error. host:#{host}, command:#{cmd}"
      return 1
    end
  end
  
  module_function :exec_block,:exec_remote,:get_host_by_tag,:get_host_by_lh

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

  
  def checkdata(host, path, data_size=50000)
    if host.empty? or path.empty?
        return [nil, 1]
    end
    retv,retc = exec_remote(host, "du -s #{path}", timeout=10)
    if retc == 0
      r = retv.split(/\t/)
      if r[0].to_i > data_size
        LOG.info "get data size.host:#{host} path:#{path} size:#{r[0]}"
        return [r[0], 0]
      else
        LOG.err "data size too short: #{path} size:#{r[0]}"
        return [r[0], 1]
      end
    else
      ERR.error "get data size error. host: #{host} path: #{path}"
      return [nil, 1]
    end
  end
  
  def checkalldata(hostlist, path, data_size=50000)
    if hostlist.size == 0 or path.empty?
      return 2
    elsif hostlist.size == 1
      retv,retc = checkdata(hostlist[0],path,data_size)
      return retc
    end
    tmpsize,tmpret = checkdata(hostlist.shift)
    if tmpret == 0
      for host in hostlist
        tmp_size,tmp_ret = checkdata(host, path, data_size)
        if tmp_ret == 0 and tmp_size == tmpsize
          LOG.info "check data size right.  host:#{host} path:#{path} size:#{tmp_size}"
          next
        else
          ERR.fatal "check data error. host:#{host} path:#{path}"
          return 1
        end
      end
    end
    return 0
  end

  module_function :checkdata,:checkalldata,:add_blacklist,:del_blacklist

end

#include OP
#p checkdata("yf-imps-npgrbs00-04.yf01", "/home/work/dynamic_data/retrbs/model")
#p get_hostlist("d0+retrms")
#p exec_block("du -sh *")

