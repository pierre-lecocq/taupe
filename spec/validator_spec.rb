# File: validator_spec.rb
# Time-stamp: <2014-09-11 15:56:04 pierre>
# Copyright (C) 2014 Pierre Lecocq
# Description: Taupe library validator tests file

describe Taupe::Validate do
  describe '#check' do
    it 'should succeed' do
      values = {
        :article_id => 1,
        :title => 'This is an article',
        :amount => 3.0
      }

      definitions = {
        :article_id => { :type => Integer, :primary_key => true },
        :amount => { :type => Float },
        :title => { :type => String, :null => false },
        :content => { :type => String }
      }

      expect(Taupe::Validate.check(values, definitions)).to eql values
    end

    it 'should send a failure' do
      values = {
        :article_id => '1',
        :title => 'This is an article',
        :content => 'and the content',
        :amount => 3.0
      }

      definitions = {
        :article_id => { :type => Integer, :primary_key => true },
        :amount => { :type => Float },
        :title => { :type => String, :null => false },
        :content => { :type => String }
      }

      expect{ Taupe::Validate.check(values, definitions) }.to raise_error
    end
  end
end
