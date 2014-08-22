# File: postgresql.rb
# Time-stamp: <2014-08-22 21:23:40 pierre>
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

        @last_id = result[0].flatten[0] if query.upcase.include? 'RETURNING'

        result
      end

      # Fetch objects from database
      # @param query [String] The query to fetch
      # @return [Array, Object]
      def fetch(query)
        exec(query).to_a.map { |row| row.symbolize_keys }
      end

      # Get last inserted id
      # @return [Integer]
      def last_id
        @last_id.to_i
      end


      # Guess schema of a table
      # @param table [String] The table name
      # @return [Hash]
      def guess_schema(table)
        query = 'SELECT column_name, data_type, character_maximum_length'
        query << ' FROM INFORMATION_SCHEMA.COLUMNS'
        query << ' WHERE table_name = \'%s\'' % table

        results = fetch query
      end
    end
  end
end
