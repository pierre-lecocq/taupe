# File: sqlite.rb
# Time-stamp: <2014-08-22 17:17:13 pierre>
# Copyright (C) 2014 Pierre Lecocq
# Description: Taupe library sqlite driver class

module Taupe
  class Database
    # Sqlite database driver
    class SqliteDriver
      # Accessors
      attr_accessor :connection

      # Constructor
      # @param [Hash] The data source name
      def initialize(dsn)
        db = File.expand_path(dsn)
        fail "Database #{db} not found" unless File.exist? db
        @connection = SQLite3::Database.new db
        @connection.results_as_hash = true
      end

      # Execute a single query
      # @param query [String] The query to execute
      # @return [Object]
      def exec(query)
        @connection.execute query
      end

      # Fetch objects from database
      # @param query [String] The query to fetch
      # @return [Array, Object]
      def fetch(query)
        exec(query).map { |row| row.symbolize_keys }
      end

      # Get last inserted id
      # @return [Integer]
      def last_id
        @connection.last_insert_row_id.to_i
      end
    end
  end
end
