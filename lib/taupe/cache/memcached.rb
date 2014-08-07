# File: memcached.rb
# Time-stamp: <2014-08-01 12:00:00 pierre>
# Copyright (C) 2014 Pierre Lecocq
# Description: Taupe library memcached driver class

module Taupe
  class Cache
    # Memcached cache driver
    class MemcachedDriver
      # Accessors
      attr_accessor :connection

      # Constructor
      # @param [Hash] The data source name
      def initialize(dsn)
        require 'memcached'
        @connection = Memcached.new dsn
      end

      # Get a cache entry
      # @param key [String] The key to retrieve
      # @return [Object]
      def self.get(key)
        @connection.get key
      end

      # Set a cache entry
      # @param key [String] The key to set
      # @param value [Object] The value
      def self.set(key, value)
        @connection.set key, value
      end

      # Delete a key
      # @param key [String] The key to delete
      def delete(key)
        @connection.delete key
      end
    end
  end
end
