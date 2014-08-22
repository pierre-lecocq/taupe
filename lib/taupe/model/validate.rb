# File: validate.rb
# Time-stamp: <2014-08-22 21:23:34 pierre>
# Copyright (C) 2014 Pierre Lecocq
# Description: Taupe library validate class

module Taupe
  # Validator class
  class Validate
    # Check data integrity
    # @param values [Hash]
    # @param definitions [Hash]
    def self.check(values, definitions)
      errors = []
      definitions.each do |name, props|
        can_be_null = props[:null] || true
        if values.include?(name)
          value = values[name]
          expected_type = props[:type] || String
          unless value.is_a? expected_type
            errors << "#{name} (#{value.class.name}) must be a #{expected_type}"
          end
        else
          errors << "#{name} can not be null" unless can_be_null
        end
      end

      fail errors.join(' - ') unless errors.empty?

      values
    end

    # Transform a SQL type into a standard type
    def sql_type_to_standard_type(sql_type)
      standard_type = nil
      case sql_type.to_s.downcase
      when 'integer'
        standard_type = Integer
      else
        standard_type = String
      end

      standard_type
    end
  end
end
