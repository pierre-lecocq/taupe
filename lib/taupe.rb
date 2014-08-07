# File: taupe.rb
# Time-stamp: <2014-08-01 12:00:00 pierre>
# Copyright (C) 2014 Pierre Lecocq
# Description: Taupe library main file

$LOAD_PATH.unshift File.join(File.dirname(__FILE__))

require 'taupe/core'
require 'taupe/database'
require 'taupe/cache'
require 'taupe/validator'
require 'taupe/model'

# Main Taupe module
module Taupe
  # Current version constant in the form major.minor.patch
  VERSION = [0, 5, 3].join('.')
end
