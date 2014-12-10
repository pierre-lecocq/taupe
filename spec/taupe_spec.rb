# File: taupe_spec.rb
# Time-stamp: <2014-12-10 16:28:36 pierre>
# Copyright (C) 2014 Pierre Lecocq
# Description: Taupe library main tests file

require_relative '../lib/taupe'

describe Taupe do
  describe 'VERSION' do
    it 'should return 0.6.4' do
      expect(Taupe::VERSION).to eql '0.6.4'
    end
  end
end
