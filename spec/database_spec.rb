# File: database_spec.rb
# Time-stamp: <2014-08-01 12:00:00 pierre>
# Copyright (C) 2014 Pierre Lecocq
# Description: Taupe library database tests file

require_relative '../lib/taupe'

describe Taupe::Database do
  # Before hook
  before :all do
    require 'sqlite3'
    path = File.expand_path('/tmp/taupe-test.db')
    File.delete path if File.exist? path
    File.new(path, 'w')
  end

  # Setup method
  describe '#setup' do
    it 'should setup the database driver' do
      database = Taupe::Database.setup do
        type :sqlite
        database File.expand_path('/tmp/taupe-test.db')
      end

      expect(database).to be_a Taupe::Database::SqliteDriver
    end
  end

  # Query method
  describe '#query' do
    it 'should execute some direct queries and return true' do
      queries = []
      queries << %Q(CREATE TABLE article(
        article_id INTEGER PRIMARY KEY AUTOINCREMENT,
        title text NOT NULL,
        content text,
        state INTEGER NOT NULL default 1,
        creation DATETIME DEFAULT CURRENT_TIMESTAMP);)
      queries << %Q(INSERT INTO article (title, content, state) VALUES (
        'Article one', 'This is the first article', 1);)
      queries << %Q(INSERT INTO article (title, content, state) VALUES (
        'Article two', 'This is the second article', 0);)
      queries.each do |q|
        expect(Taupe::Database.exec(q)).to eql []
      end
    end
  end

  # Fetch method
  describe '#fetch' do
    it 'should fetch two database entries' do
      q = 'SELECT * FROM article'
      results = Taupe::Database.fetch(q)
      expect(results).to be_a Array
      expect(results[0]).to be_a Hash
      expect(results.length).to eql 2
    end
  end
end
