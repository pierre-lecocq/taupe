# File: sqlite.rb
# Time-stamp: <2014-09-11 15:01:58 pierre>
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
        exec(query).map(&:symbolize_keys)
      end

      # Get last inserted id
      # @return [Integer]
      def last_id
        @connection.last_insert_row_id.to_i
      end

      # Guess schema of a table
      # @param table [String] The table name
      # @return [Hash]
      def guess_schema(table)
        results = {}

        query = format('pragma table_info(%s)', table)

        fetch(query).each do |values|
          type = Taupe::Validate.standardize_sql_type values[:type]

          results[values[:name].to_sym] = {
            type: type,
            null: values[:notnull] == 0,
            primary_key: values[:pk] == 1
          }
        end

        results
      end

      # Escape a string
      # @param str [String]
      # @return [String]
      def escape(str)
        # Sqlite3 does not implement this kind of thing
        # Use prepare statements instead
        str
      end
    end
  end
end
