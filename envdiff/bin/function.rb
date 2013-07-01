#coding: utf-8
$: << File.dirname(__FILE__)


require "find"
require "pathname"


module SA

  def list_file(directory)
    #  @return val: 
    #        1 : file not exist
    #        2 : argument err
    filelist = []
    dirlist = []
    other = []
    #Check argument type
    if not directory.is_a? String
      p "Argumen error func:#{__method__}"
      return 2
    end

    #check existance
    if not FileTest.exists? directory
      p "func:#{__method__} directory:#{directory} doesn't exist"
      return 1
    end

    if FileTest.symlink? directory
      directory = Pathname.new(directory).realpath.to_path
    end

    #walk a directory, follow the symlink
    walkdir = Proc.new { |dir|
      Find.find(dir) do |path|
        if FileTest.symlink? path
          directory = Pathname.new(path).realpath.to_path
            walkdir.call directory
        end
        if FileTest.file? path
          filelist << path
        elsif FileTest.directory? path
          dirlist << path
        else
          other << path
        end
      end
    }

    walkdir.call directory

    return filelist,dirlist,other
  end

  def hashdiff(h1,h2)
    #compare two hash, get the difference

    #check type
    if not h1.is_a? Hash or not h2.is_a? Hash
      p "object type wrong"
      return 1
    end

    #check size
    if h1.size == 0 and h2.size == 0
      return {}
    elsif h1.size == 0 and h2.size != 0
      return h2
    elsif h1.size != 0 and h2.size == 0
      return h1
    end

    not_equal = []
    value_equal = {}

    #compare keys
    keys_h1 = h1.keys
    keys_h2 = h2.keys
    keys_in_both = keys_h1 & keys_h2
    keys_only_in_h1 = keys_h1 - keys_h2
    keys_only_in_h2 = keys_h2 - keys_h1
    
    #p "key in both: #{keys_in_both.to_s}"
    #p "key only in h1: #{keys_only_in_h1.to_s}"
    #p "key only in h2: #{keys_only_in_h2.to_s}"
   
    keys_in_both.map do |key|
      if h1[key].eql? h2[key]
        value_equal[key] = h1[key]
      else
        not_equal << {key=>[h1[key],h2[key]]}
      end
    end

    return not_equal, keys_only_in_h1.map {|key| {key=>h1[key]}}, keys_only_in_h2.map {|key| {key=>h2[key]}}, value_equal

  end

  module_function :list_file,:hashdiff

end


#p SA::list_file("/home/work/getfile")
#p SA::hashdiff({:a=>1,:b=>2,:c=>3},{:a=>1,:b=>3,:d=>4})
