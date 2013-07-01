#coding: utf-8
$: << File.dirname(__FILE__)


require 'rubygems'
require 'forkmanager'
require 'common'

Hostfile = "/home/work/change_model/hostlist"
Hostlist = []
Faillist = []
Successlist = []
Failfile = "failhost"
cmd = "du -sh dynamic_data/restart"

max_procs = 5

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
       p "change model on host:#{host} error"
       pm.finish(1, host)
     end
     pm.finish(0, host) # pass an exit code to finish
}

print "Waiting for Children...\n"
pm.wait_all_children

p "faillist: #{Faillist}"
p "successlist: #{Successlist}"

if not Faillist.empty?
  f = File.open(Failfile, "w")
    Faillist.each do |host| 
      f.write(host+'\n')
    end
  f.close
end

