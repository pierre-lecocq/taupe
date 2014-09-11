#!/usr/bin/env ruby

# File: table.rb
# Time-stamp: <2014-09-11 16:28:23 pierre>
# Copyright (C) 2014 Pierre Lecocq
# Description: Taupe library model table class

module Taupe
  class Model
    # Model table base class
    class Table
      # Set instance variables
      class << self
        attr_accessor :_cname, :_table, :_columns
        attr_accessor :_pkey, :_values, :_pkey_id, :_cache_key
      end

      # Load a new object
      # @param pkey_id [Numeric]
      # @param cache_key [String]
      def self.load(pkey_id = nil, cache_key = nil)
        full_cname = "Taupe::Model::#{@_cname}"
        klass = full_cname.split('::').reduce(Object) { |a, e| a.const_get e }

        options = {
          pkey_id: pkey_id,
          cache_key: cache_key,
          values: nil
        }

        klass.new @_table, @_columns, options
      end

      # Load a new object from existing values
      # @param values [Hash]
      # @param pkey_id [Numeric]
      # @param cache_key [String]
      def self.load_from_hash(values, pkey_id = nil, cache_key = nil)
        full_cname = "Taupe::Model::#{@_cname}"
        klass = full_cname.split('::').reduce(Object) { |a, e| a.const_get e }

        options = {
          pkey_id: pkey_id,
          cache_key: cache_key,
          values: values
        }

        klass.new @_table, @_columns, options
      end

      # Constructor
      # @param table [String]
      # @param columns [Hash]
      # @param options [Hash]
      def initialize(table, columns = nil, options = {})
        columns = Taupe::Database.guess_schema(table) if columns.nil?

        @_table = table
        @_columns = columns
        @_pkey = nil
        @_pkey_id = options[:pkey_id] || nil
        @_cache_key = options[:cache_key] || nil
        @_values = options[:values] || {}

        @_pkey = columns.select { |_k, v| v[:primary_key] == true }.first[0]
        fail "Primary key undefined for model #{table}" if @_pkey.nil?

        if @_values.empty?
          return if @_pkey_id.nil?
          retrieve_from_database unless retrieve_from_cache
        else
          @_pkey_id = @_values[@_pkey] if @_pkey_id.nil?
        end
      end

      # Retrieve data from cache
      # @return [Boolean]
      def retrieve_from_cache
        retrieved = false
        return retrieved if @_cache_key.nil?

        data = Taupe::Cache.get(@_cache_key) || nil
        unless data.nil? || data.empty?
          @_values = data
          retrieved = true
        end

        retrieved
      end

      # Retrieve data from database
      def retrieve_from_database
        query = "SELECT * FROM #{@_table} WHERE #{@_pkey} = #{@_pkey_id}"
        result = Taupe::Database.fetch(query, true)

        return nil if result.nil? || result.empty?

        result.map do |k, v|
          @_values[k.to_sym] = v unless k.is_a? Numeric
        end

        Taupe::Cache.set @_cache_key, @_values unless @_cache_key.nil?
      end

      # Save the model object
      # @param with_validations [Boolean]
      def save(with_validations = true)
        Taupe::Validate.check(@_values, @_columns) if with_validations

        if @_pkey_id.nil?
          query = "
            INSERT INTO #{@_table}
               (#{@_values.keys.map(&:to_s).join(', ')})
            VALUES
               (#{@_values.values.map { |e| "'" + e.to_s + "'" }.join(', ')})
          "

          Taupe::Database.exec query
          @_pkey_id = Taupe::Database.last_id
        else
          joined_values = @_values.map { |k, v| "#{k} = '#{v}'" }.join(', ')
          query = "
            UPDATE #{@_table} SET #{joined_values}
            WHERE #{@_pkey} = #{@_pkey_id}
          "

          Taupe::Database.exec query
        end

        Taupe::Cache.delete @_cache_key unless @_cache_key.nil?
      end

      # Delete the model object
      def delete
        fail 'Can not delete an unsaved model object' if @_pkey_id.nil?

        query = "DELETE FROM #{@_table} WHERE #{@_pkey} = #{@_pkey_id}"

        Taupe::Database.exec query

        Taupe::Cache.delete @_cache_key unless @_cache_key.nil?
      end

      # Is the object empty?
      # @return [Boolean]
      def empty?
        @_values.empty?
      end

      # Method missing
      def method_missing(m, *args, &block)
        return @_pkey_id if m.to_sym == @_pkey.to_sym
        return @_values[m] if @_values.key? m

        ms = m.to_s
        if ms.include? '='
          ms = ms[0..-2]
          if @_columns.include? ms.to_sym
            @_values[ms.to_sym] = args[0]
            return true
          end
        end

        super
      end

      # Execute a single query
      # @param query [String] The query to execute
      # @return [Object]
      def self.exec(query)
        Taupe::Database.exec query
      end

      # Fetch objects from database
      # @param query [String] The query to fetch
      # @param single [Boolean] Must return one or more results?
      # @return [Array, Object]
      def self.fetch(query, single = false)
        results = []
        data = Taupe::Database.fetch(query)

        if data
          data.each do |h|
            results << load_from_hash(h)
          end
        end

        single ? results[0] : results
      end
    end
  end
end
