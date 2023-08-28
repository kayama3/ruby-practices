# /usr/bin/env ruby
# frozen_string_literal: true

require 'etc'
require 'optparse'
require_relative '../lib/command'

opt = OptionParser.new

params = { dotmatch: false, reverse: false, long_format: false }
opt.on('-a') { |v| params[:dotmatch] = v }
opt.on('-r') { |v| params[:reverse] = v }
opt.on('-l') { |v| params[:long_format] = v }
opt.parse!(ARGV)

LS::Command.new(**params).exec
