#!/usr/bin/env ruby

`ls #{ARGV[0]}| xargs -n 2`
  .split("\n")
  .each{|line|
    system "zcmp -s #{line}" or (
      puts "#{line} differ"
      system "vim -d #{line}"
    )
  }
