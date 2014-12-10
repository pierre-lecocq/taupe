# File: taupe_spec.rb
# Time-stamp: <2014-12-10 15:42:44 pierre>
# Copyright (C) 2014 Pierre Lecocq
# Description: Taupe library main tests file

require_relative '../lib/taupe'

describe Taupe do
  describe 'VERSION' do
    it 'should return 0.6.2' do
      expect(Taupe::VERSION).to eql '0.6.2'
    end
  end
end
