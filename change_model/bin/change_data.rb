#coding: utf-8
$: << File.dirname(__FILE__)


require 'rubygems'
require 'forkmanager'
require 'common'

require 'log'
require 'conf'


include Mylog



#{(CONFDIR+$Conf_file).to_path}
Hostfile = (CONFDIR+CONF["HOSTLIST"]).to_path
Hostlist = []
Faillist = []
Successlist = []
Failfile = "failhost"

src="/home/work/dynamic_data/restart/model.new"
dst="/home/work/dynamic_data/retrms/model"

cmd = "[ -d #{src} ] && rm -rf #{dst}.bak && mv #{dst} #{dst}.bak && mv #{src} #{dst}"
#cmd = "[ -d /home/work/dynamic_data/restart/model.new ] && echo model.new "

max_procs = 10

#get host list
File.open(Hostfile) do |f|
  f.each {|line| Hostlist << line.strip}
end

pm = Parallel::ForkManager.new(max_procs,{'tempdir' => '/tmp'}, 0)

# Setup a callback for when a child finishes up so we can get it's exit code
pm.run_on_finish { # called BEFORE the first call to start()
     |pid,exit_code,ident,exit_signal,core_dump,data_structure|

     # retrieve data structure from child
     if defined? data_structure # children are not forced to send anything
       if exit_code == 0
         Successlist << data_structure
       else
         Faillist << data_structure
       end
     end
}

Hostlist.each {
     |host|
     pid = pm.start(host) and next

     # The code in the child process
     out,ret = OP::exec_remote(host,cmd,timeout=120)
     p "output:#{out}, ret:#{ret}"
     if ret != 0
       ERR.error "change data on host:#{host} error"
       pm.finish(1, host)
     end
     LOG.info "change data on host:#{host} success"
     pm.finish(0, host) # pass an exit code to finish
}

pm.wait_all_children


if not Faillist.empty?
  f = File.open(Failfile, "w")
    Faillist.each do |host| 
      f.write(host+"\n")
    end
  f.close
  exit 1
end

