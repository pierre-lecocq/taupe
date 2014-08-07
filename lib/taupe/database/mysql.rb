# File: mysql.rb
# Time-stamp: <2014-08-01 12:00:00 pierre>
# Copyright (C) 2014 Pierre Lecocq
# Description: Taupe library mysql driver class

module Taupe
  class Database
    # Mysql database driver
    class MysqlDriver
      # Accessors
      attr_accessor :connection

      # Constructor
      # @param [Hash] The data source name
      def initialize(dsn)
        require 'mysql2'
        dsn[:host] = '127.0.0.1' if dsn[:host].to_s == 'localhost'
        @connection = Mysql2::Client.new dsn
        @connection.query_options.merge! symbolize_keys: true
      end

      # Execute a single query
      # @param query [String] The query to execute
      # @return [Object]
      def exec(query)
        @connection.query query
      end

      # Fetch objects from database
      # @param query [String] The query to fetch
      # @param single [Boolean] Must return one or more results?
      # @return [Array, Object]
      def fetch(query)
        exec(query).to_a
      end

      # Get last inserted id
      # @return [Integer]
      def last_id
        @connection.last_id.to_i
      end
    end
  end
end