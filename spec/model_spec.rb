# File: model_spec.rb
# Time-stamp: <2014-12-10 16:27:47 pierre>
# Copyright (C) 2014 Pierre Lecocq
# Description: Taupe library model tests file

require_relative '../lib/taupe'

describe Taupe::Model do

  # Setup method
  describe '#setup' do
    it 'should setup the Article model' do
      model = Taupe::Model.setup do
        table :article
        column :article_id, { type: Integer, :primary_key => true }
        column :title, { type: String, :null => false }
        column :content, { type: String }
        column :state, { type: Integer }
        column :creation, { type: Date, :locked => true }
      end
      expect(model).to be_a Taupe::Model

      model_object = Taupe::Model::Article.load
      expect(model_object).to be_a Taupe::Model::Article
    end
  end

  # Fetch method
  describe '#fetch' do
    it 'should fetch data from Article' do
      query = "SELECT * FROM article"
      results = Taupe::Model::Article.fetch(query)

      expect(results).to be_a Array
      expect(results.length).to eql 2
    end
  end

  # Query method
  describe '#query and #save' do
    it 'should execute an insert into Article' do
      model_object = Taupe::Model::Article.load
      model_object.title = 'This is a new article'
      model_object.content = 'This is a new article content'
      model_object.state = 1
      model_object.save

      query = "SELECT * FROM article"
      results = Taupe::Model::Article.fetch(query)

      expect(results).to be_a Array
      expect(results.length).to eql 3
      expect(results.last.title).to eql 'This is a new article'
    end
  end

  # Types
  describe 'types' do
    it 'should return an object and transform it to an Hash' do
      query = "SELECT * FROM article WHERE article_id = 1"
      result = Taupe::Model::Article.fetch(query, true)
      expect(result).to be_a Taupe::Model::Article
      hash_result = result.to_hash
      expect(hash_result).to be_a Hash
    end
  end
end
