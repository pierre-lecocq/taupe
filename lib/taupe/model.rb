# File: model.rb
# Time-stamp: <2014-08-22 17:22:45 pierre>
# Copyright (C) 2014 Pierre Lecocq
# Description: Taupe library model class

require 'taupe/model/table'
require 'taupe/model/validate'

module Taupe
  # Model class
  class Model
    # Includes
    include Accessorized

    # Custom accessors
    # Accessible via _name and _name=
    single_accessor :table
    stacked_accessor :column

    # Accessors
    attr_accessor :instance

    # Setup the Cache instance
    # @param block [Proc] A given block
    def self.setup(&block)
      @instance = new(&block)
    end

    # Constructor
    # @param block [Proc] A given block
    def initialize(&block)
      instance_eval(&block)
      _write_class_code
    end

    # Build the table related class
    def _write_class_code
      cname = @table.to_s.split('_').map(&:capitalize).join
      klass = Taupe::Model.const_set cname, Class.new(Taupe::Model::Table)
      klass._cname = cname
      klass._table = @table
      klass._columns = @_column_stack
    end

    private :_write_class_code
  end
end
