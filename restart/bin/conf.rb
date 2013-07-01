#coding: utf-8
$: << File.dirname(__FILE__)


require "pathname"
require "yaml"

$Conf_file = "op.conf"

module Conf

  def get_rootdir    #re-construct
    Dir.chdir("..")
    Dir.pwd
  end
 
  def read_conf(conf_file)
    YAML::load(File.open(conf_file))
  end
 
  def dump_conf(conf_file, conf)
    YAML::dump(conf, File.open(conf_file, "w"))
  end

  module_function :get_rootdir,:read_conf,:dump_conf
 
  ROOTPATH = Pathname.new("#{get_rootdir}")
  LOGDIR = ROOTPATH + "log"
  CONFDIR = ROOTPATH + "bin"
  BINDIR = ROOTPATH + "bin"
  #Dir.chdir(BINDIR.to_path)
   
  CONF = read_conf("#{(CONFDIR+$Conf_file).to_path}")

end 

