# File: database.rb
# Time-stamp: <2014-09-11 14:52:41 pierre>
# Copyright (C) 2014 Pierre Lecocq
# Description: Taupe library database class

require 'taupe/database/postgresql'
require 'taupe/database/mysql'
require 'taupe/database/sqlite'

module Taupe
  # Database class
  # Manage database connection and serve as query proxy
  class Database
    # Includes
    include Accessorized

    # Custom accessors
    # Accessible via _name and _name=
    single_accessor :type, :host, :port, :username, :password, :database

    # Accessors
    attr_accessor :instance, :driver

    # Constructor
    # @param block [Proc] A given block
    def initialize(&block)
      instance_eval(&block)
    end

    # Setup the Database instance
    # @param block [Proc] A given block
    def self.setup(&block)
      @instance = new(&block)
      setup_defaults
      driver_factory
    end

    # Get the database type
    # @return [Symbol]
    def self.type
      @instance._type
    end

    # Get the database name
    # @return [Symbol]
    def self.database
      @instance._database
    end

    # Setup default values
    def self.setup_defaults
      case @instance._type
      when :pg, :pgsql, :postgres, :postgresql
        Taupe.require_gem 'pg', 'PostgreSQL database engine'
        @instance._type = :postgresql
        @instance._host ||= :localhost
        @instance._port ||= 5432
      when :mysql, :mysql2
        Taupe.require_gem 'mysql2', 'MySQL database engine'
        @instance._type = :mysql
        @instance._host ||= :localhost
        @instance._port ||= 3306
      when :sqlite, :sqlite3
        Taupe.require_gem 'sqlite3', 'SQLite database engine'
        @instance._type = :sqlite
        @instance._database ||= File.expand_path('~/.taupe.db')
      else
        fail 'Unknown database type'
      end
    end

    # Get the data source name
    # @return [Hash]
    def self.dsn
      case @instance._type
      when :postgresql
        {
          host: @instance._host.to_s,
          user: @instance._username.to_s,
          password: @instance._password.to_s,
          dbname: @instance._database.to_s
        }
      when :mysql
        {
          host: @instance._host.to_s,
          username: @instance._username.to_s,
          password: @instance._password.to_s,
          database: @instance._database.to_s
        }
      when :sqlite
        @instance._database.to_s
      end
    end

    # Setup the connection driver
    def self.driver_factory
      cname = "Taupe::Database::#{@instance._type.capitalize}Driver"
      klass = cname.split('::').reduce(Object) { |a, e| a.const_get e }
      @instance.driver = klass.new dsn
    end

    # Guess schema of a table
    # @param table [String] The table name
    # @return [Hash]
    def self.guess_schema(table)
      @instance.driver.guess_schema table
    end

    # Execute a single query
    # @param query [String] The query to execute
    # @return [Object]
    def self.exec(query)
      @instance.driver.exec query
    end

    # Fetch objects from database
    # @param query [String] The query to fetch
    # @param single [Boolean] Must return one or more results?
    # @return [Array, Object]
    def self.fetch(query, single = false)
      results = @instance.driver.fetch query
      single ? results[0] : results
    end

    # Fetch last inserted id
    # @return [Integer]
    def self.last_id
      @instance.driver.last_id
    end

    # Escape a string
    # @param str [String]
    # @return [String]
    def self.escape(str)
      @instance.driver.escape str
    end
  end
end
