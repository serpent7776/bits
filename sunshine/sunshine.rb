#!/usr/bin/env ruby
print("[ #{('☀️' * 8).grapheme_clusters.map{|s| s + ','}.join(' ').chop} ]\n")
