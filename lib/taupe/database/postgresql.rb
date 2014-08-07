# File: postgresql.rb
# Time-stamp: <2014-08-01 12:00:00 pierre>
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
        require 'pg'
        @connection = PG::Connection.new dsn
      end

      # Execute a single query
      # @param query [String] The query to execute
      # @return [Object]
      def exec(query)
        result = @connection.exec query
        if query.upcase.include? 'RETURNING'
          @last_id = result[0].flatten[0]
        end

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

    end
  end
end
