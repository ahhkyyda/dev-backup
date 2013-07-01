#!/home/work/opbin/ruby/bin/ruby
#coding: utf-8
$: << File.dirname(__FILE__)


require 'conf'
require 'common'

mapfile = (Conf::CONFDIR+"map_lh_nodes").to_path
load mapfile


def diff_host(h1,h2)
  if (not h1.is_a? Array) or (not h2.is_a? Array)
    #p "host array type error"
    return 1
  end
  if h1.size == 0 or h2.size == 0
    return 1
  end
  if (h1 - h2).size != 0
    return 1
  else
    return 0
  end
end


def print_diff(h1, h2, h1_list, h2_list)
  p "-"*80
  space = " "*(10-5/2-1)
  s1 = "#{space}#{h1}#{space} "
  s2 = "#{space}#{h2}#{space} "
  printf "|%s|%-40s|\n",s1,s2
  p "-"*80
  size = h1_list.length >= h2_list.length ? h1_list.size : h2.length
  n = 0
  while n < size
    printf "|\033[33m%-40s\033[0m|\033[33m%-40s\033[0m|\n",h1_list[n],h2_list[n]
    n += 1
  end
  p "-"*80
end


$rules.each do |d|
  h1_list = OP::get_host_by_lh(d[:qstring])
  h2_list = OP::get_host_by_tag(d[:tag].join("+"))
  if diff_host(h1_list,h2_list) == 0
    printf "\033[32mhost check pass.\033[0m nodes: %s, qstring: %s\n",d[:tag].join("+"),d[:qstring]
  else
    printf "\033[31mhost in nodes and qstring not match.\033[0m nodes: %s, qstring: %s\n",d[:tag].join("+"),d[:qstring]
    print_diff(d[:qstring], d[:tag].join("+"), h1_list, h2_list)
  end
end


