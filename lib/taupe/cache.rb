# File: cache.rb
# Time-stamp: <2014-08-01 12:00:00 pierre>
# Copyright (C) 2014 Pierre Lecocq
# Description: Taupe library cache class

require 'taupe/cache/memcached'
require 'taupe/cache/redis'

module Taupe
  # Cache class
  # Manage cache connection and serve as query proxy
  class Cache
    # Includes
    include Accessorized

    # Custom accessors
    # Accessible via _name and _name=
    single_accessor :type, :host, :port

    # Accessors
    attr_accessor :instance, :driver

    # Constructor
    # @param block [Proc] A given block
    def initialize(&block)
      instance_eval(&block)
    end

    # Setup the Cache instance
    # @param block [Proc] A given block
    def self.setup(&block)
      @instance = new(&block)
      setup_defaults
      driver_factory
    end

    # Setup default values
    def self.setup_defaults
      case @instance._type
      when :memcached
        @instance._host ||= :localhost
        @instance._port ||= 11_211
      when :redis
        @instance._host ||= :localhost
        @instance._port ||= 6379
      else
        fail 'Unknown cache type'
      end
    end

    # Get the data source name
    # @return [Hash, String]
    def self.dsn
      case @instance._type
      when :memcached
        "#{@instance._host}:#{@instance._port}"
      when :redis
        {
          host: @instance._host.to_s,
          port: @instance._port.to_i
        }
      end
    end

    # Setup the connection driver
    def self.driver_factory
      cname = "Taupe::Cache::#{@instance._type.capitalize}Driver"
      klass = cname.split('::').reduce(Object) { |a, e| a.const_get e }
      @instance.driver = klass.new dsn
    end

    # Get a cache entry
    # @param key [String] The key to retrieve
    # @return [Object]
    def self.get(key)
      @instance.driver.get key
    end

    # Set a cache entry
    # @param key [String] The key to set
    # @param value [Object] The value
    def self.set(key, value)
      @instance.driver.set key, value
    end

    # Delete a key
    # @param key [String] The key to delete
    def delete(key)
      @instance.driver.delete key
    end
  end
end
