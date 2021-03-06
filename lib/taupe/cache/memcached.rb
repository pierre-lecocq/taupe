# File: memcached.rb
# Time-stamp: <2014-09-11 16:30:12 pierre>
# Copyright (C) 2014 Pierre Lecocq
# Description: Taupe library memcached driver class

module Taupe
  class Cache
    # Memcached cache driver
    class MemcachedDriver
      # Accessors
      attr_accessor :connection

      # Constructor
      # @param dsn [Hash] The data source name
      def initialize(dsn)
        @connection = Memcached.new dsn
      end

      # Get a cache entry
      # @param key [String] The key to retrieve
      # @return [Object]
      def get(key)
        @connection.get key.to_s
      end

      # Set a cache entry
      # @param key [String] The key to set
      # @param value [Object] The value
      def set(key, value)
        @connection.set key.to_s, value
      end

      # Delete a key
      # @param key [String] The key to delete
      def delete(key)
        @connection.delete key.to_s
      end
    end
  end
end
