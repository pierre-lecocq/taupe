# File: taupe_spec.rb
# Time-stamp: <2014-12-10 14:45:38 pierre>
# Copyright (C) 2014 Pierre Lecocq
# Description: Taupe library main tests file

require_relative '../lib/taupe'

describe Taupe do
  describe 'VERSION' do
    it 'should return 0.6.0' do
      expect(Taupe::VERSION).to eql '0.6.0'
    end
  end
end
