# File: postgresql.rb
# Time-stamp: <2014-09-11 16:11:17 pierre>
# Copyright (C) 2014 Pierre Lecocq
# Description: Taupe library postgresql driver class

module Taupe
  class Database
    # Postgresql database driver
    class PostgresqlDriver
      # Accessors
      attr_accessor :connection, :last_id

      # Constructor
      # @param [Hash] The data source name
      def initialize(dsn)
        @connection = PG::Connection.new dsn
      end

      # Execute a single query
      # @param query [String] The query to execute
      # @return [Object]
      def exec(query)
        result = @connection.exec query

        @last_id = nil
        @last_id = result[0].flatten[0] if query.upcase.include?('RETURNING')

        result
      end

      # Fetch objects from database
      # @param query [String] The query to fetch
      # @return [Array, Object]
      def fetch(query)
        exec(query).to_a.map(&:symbolize_keys)
      end

      # Get last inserted id
      # @return [Integer]
      def last_id
        if @last_id.nil?
          message = 'Last ID can not be retrieved.'
          message << ' Maybe the last query did not include "RETURNING"'

          warn message
        end

        @last_id.to_i
      end

      # Guess schema of a table
      # @param table [String] The table name
      # @return [Hash]
      def guess_schema(table)
        results = {}

        query = 'SELECT'
        query << ' column_name, data_type, character_maximum_length,'
        query << ' column_default, is_nullable'
        query << ' FROM INFORMATION_SCHEMA.COLUMNS'
        query << format(' WHERE table_name = \'%s\'', table)
        query << ' ORDER BY ordinal_position'

        fetch(query).each do |values|
          type = Taupe::Validate.standardize_sql_type values[:data_type]
          pkey = false
          unless values[:column_default].nil?
            pkey = true unless values[:column_default].match('nextval').nil?
          end

          results[values[:column_name].to_sym] = {
            type: type,
            null: values[:is_nullable] != 'NO',
            primary_key: pkey
          }
        end

        results
      end

      # Escape a string
      # @param str [String]
      # @return [String]
      def escape(str)
        @connection.escape_string str
      end
    end
  end
end
