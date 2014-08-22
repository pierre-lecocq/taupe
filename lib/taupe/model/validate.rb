# File: validate.rb
# Time-stamp: <2014-08-22 16:33:01 pierre>
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
  end
end
