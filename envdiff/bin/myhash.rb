#coding: utf-8
$: << File.dirname(__FILE__)
    
      
require "digest/md5"

module Myhash
  #30m
  Bigfile_size = 30000000
  #300m
  Mbigfile_size = 300000000
  Read_size_s = 5000000
  Read_size_b = 10000000

  def md5(obj)
    #compute md5, support string and file 
    if obj.is_a? String
      return Digest::MD5.hexdigest(obj)
    elsif FileTest.file? obj
      f = open(obj,"rb")
      c = f.read
      f.close
      return Digest::MD5.hexdigest(c)
    else
      p "obj: #{obj} type not supported"
      return 1
    end
  end

  def fast_md5(obj)
    if FileTest.file? obj
      fsize = File.size(obj)
      f = File.open(obj,"rb")
      read_size = 0
      if fsize < Bigfile_size
        return md5(f.read)
      elsif fsize >= Bigfile_size and fsize <= Mbigfile_size
        read_size = Read_size_s
      elsif fsize > Mbigfile_size
        read_size = Read_size_b
      end
        first_part = f.read(read_size)
        md5_first = md5(first_part)
        first_part = 0
        f.seek(fsize/2-read_size/2)
        second_part = f.read(read_size)
        md5_second = md5(second_part)
        second_part = 0
        f.seek(fsize-read_size)
        third_part = f.read(read_size)
        md5_third = md5(third_part)
        third_part = 0
      return md5(md5_first + md5_second + md5_third)
    elsif obj.is_a? String
      return Digest::MD5.hexdigest(obj)
    else
      p "obj: #{obj} type not supported"
      return 1
    end
  end


  module_function :md5, :fast_md5
end

#p Myhash::md5("test null")
p Myhash::fast_md5("/home/work/get_explore/explore/offkey/key_cluster.index.ind2")
#p Myhash::fast_md5("test")

