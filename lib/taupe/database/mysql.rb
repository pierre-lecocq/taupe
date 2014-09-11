# File: mysql.rb
# Time-stamp: <2014-09-11 14:57:57 pierre>
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

      # Guess schema of a table
      # @param table [String] The table name
      # @return [Hash]
      def guess_schema(table)
        results = {}

        query = format('SHOW COLUMNS FROM %s', table)

        fetch(query).each do |values|
          type = Taupe::Validate.standardize_sql_type values[:Type]

          results[values[:Field].to_sym] = {
            type: type,
            null: values[:Null] != 'NO',
            primary_key: values[:Key] == 'PRI'
          }
        end

        results
      end

      # Escape a string
      # @param str [String]
      # @return [String]
      def escape(str)
        @connection.escape str
      end
    end
  end
end
