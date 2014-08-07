# File: model_spec.rb
# Time-stamp: <2014-08-01 12:00:00 pierre>
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
  describe '#query' do
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
      expect(results.last[:title]).to eql 'This is a new article'
    end
  end
end
