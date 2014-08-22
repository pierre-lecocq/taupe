# File: taupe.rb
# Time-stamp: <2014-08-22 17:03:26 pierre>
# Copyright (C) 2014 Pierre Lecocq
# Description: Taupe library main file

$LOAD_PATH.unshift File.join(File.dirname(__FILE__))

require 'taupe/core'
require 'taupe/database'
require 'taupe/cache'
require 'taupe/model'

# Main Taupe module
module Taupe
  # Current version constant in the form major.minor.patch
  VERSION = [0, 5, 3].join('.')

  # Require a gem
  # @param gem [String] the gem name
  # @param description [String] a description of the gem
  def self.require_gem(gem_name, description)
    require gem_name
  rescue LoadError
    fail 'In order to use %s, install the gem "%s"' % [
      description,
      gem_name
    ]
  end
end
