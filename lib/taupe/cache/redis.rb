# File: redis.rb
# Time-stamp: <2014-08-22 17:17:28 pierre>
# Copyright (C) 2014 Pierre Lecocq
# Description: Taupe library redis driver class

module Taupe
  class Cache
    # Redis cache driver
    class RedisDriver
      # Accessors
      attr_accessor :connection

      # Constructor
      # @param [Hash] The data source name
      def initialize(dsn)
        @connection = Redis.new dsn
      end

      # Get a cache entry
      # @param key [String] The key to retrieve
      # @return [Object]
      def get(key)
        @connection.hgetall(key).symbolize_keys
      end

      # Set a cache entry
      # @param key [String] The key to set
      # @param value [Object] The value
      def set(key, value)
        fail 'Only HASH values are supported' unless value.is_a?(Hash)
        @connection.mapped_hmset key, value
      end

      # Delete a key
      # @param key [String] The key to delete
      def delete(key)
        @connection.del key
      end
    end
  end
end
