# File: taupe.rb
# Time-stamp: <2014-08-22 15:51:39 pierre>
# Copyright (C) 2014 Pierre Lecocq
# Description: Taupe library main file

$LOAD_PATH.unshift File.join(File.dirname(__FILE__))

require 'taupe/database'
require 'taupe/cache'
require 'taupe/model'

# Main Taupe module
module Taupe
  # Current version constant in the form major.minor.patch
  VERSION = [0, 5, 3].join('.')

  # Accessorized module
  # Add the ability to set custom accessor to a class
  module Accessorized
    # Extend ClassMethods
    # @param base [Object] The caller object
    def self.included(base)
      base.extend(ClassMethods)
    end

    # Class methods
    module ClassMethods
      # Define single accessor. It can be set one time.
      # @example single_accessor :name
      # @note The getter is "_name" instead of "name"
      # @param names [Array] Set of names
      def single_accessor(*names)
        names.each do |name|
          define_method name do |data|
            instance_variable_set "@#{name}".to_sym, data
          end
          define_method "_#{name}" do
            instance_variable_get "@#{name}".to_sym
          end
          define_method "_#{name}=" do |data|
            instance_variable_set "@#{name}".to_sym, data
          end
        end
      end

      # Define stacked accessor. It can be set several times.
      # @example stacked_accessor :name, { type; String, null; false }
      # @note The getter is "_name_stack" instead of "name"
      # @param names [Array] Set of names, and a hash of values
      def stacked_accessor(*names)
        names.each do |name|
          define_method name do |*data|
            stack = instance_variable_get("@_#{name}_stack".to_sym) || {}
            stack[data[0]] = data[1]
            instance_variable_set "@_#{name}_stack".to_sym, stack
          end
          define_method "_#{name}_stack" do
            instance_variable_get "@_#{name}_stack".to_sym
          end
        end
      end
    end
  end
end

# Hash ruby core class monkey patching (yes, this is ugly)
class Hash
  # Symbolize keys (credits to Avdi Grimm)
  def symbolize_keys
    each_with_object({}) do |(key, value), result|
      new_key = case key
                when String then key.to_sym
                else key
                end
      new_val = case value
                when Hash then symbolize_keys(value)
                else value
                end
      result[new_key] = new_val

      result
    end
  end
end
