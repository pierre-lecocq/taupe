#!/usr/bin/env ruby

# File: bookmarker.rb
# Time-stamp: <2014-09-11 15:54:05 pierre>
# Copyright (C) 2014 Pierre Lecocq
# Description: Taupe library sample app

=begin

Sample commands:

  ruby bookmarker.rb --init

  ruby bookmarker.rb --add --url https://github.com/pierre-lecocq/emacs.d --name "My emacs config" --tags emacs
  ruby bookmarker.rb --add --url http://planet.emacsen.org/ --name "Planet emacsen" --tags emacs,blog
  ruby bookmarker.rb -a -u https://github.com/pierre-lecocq/dockstack -n Dockstack -t docker

  ruby bookmarker.rb -l
  ruby bookmarker.rb --list
  ruby bookmarker.rb --list --tags emacs
  ruby bookmarker.rb -l -t emacs

  ruby bookmarker.rb --delete --id 2
  ruby bookmarker.rb -d -i 2

=end

require 'optparse'
require_relative '../../lib/taupe'

# Define a database backend

path = File.expand_path('./bookmarker.db')
File.new(path, 'w') unless File.exist? path
Taupe::Database.setup do
  type :sqlite
  database File.expand_path('./bookmarker.db')
end

# Define a cache backend

# Taupe::Cache.setup do
#   type :memcached
# end

# Define models

Taupe::Model.setup do
  table :tag
  column :tag_id,      { type: Integer, :primary_key => true }
  column :name,        { type: String, :null => false }
end

Taupe::Model.setup do
  table :bookmark
  column :bookmark_id, { type: Integer, :primary_key => true }
  column :name,        { type: String, :null => false }
  column :url,         { type: String, :null => false }
end

# The bookmarker class
class Bookmaker
  # Accessors
  attr_accessor :options

  # Constructor
  def initialize(options)
    @options = options
    _dispatch
  end

  # Verify options and dispatch
  def _dispatch
    case @options[:action]
    when :init
      _init
    when :add
      fail 'No url given (-u option)' if @options[:url].empty?
      fail 'No name given (-n option)' if @options[:name].empty?
      _add
    when :delete
      fail 'No id given (-i option)' if @options[:id].nil?
      _delete
    when :list
      _list
    else
      fail "Unknown action #{@options[:action]}"
    end
  end

  # Add a new bookmark
  def _add
    # Load a new bookmark object
    bookmark = Taupe::Model::Bookmark.load

    # Modify properties
    bookmark.url = @options[:url]
    bookmark.name = @options[:name]

    # Save in database and cache
    bookmark.save

    # Tags?
    unless @options[:tags].empty?
      @options[:tags].each do |tag_name|
        tag = Taupe::Model::Tag.fetch "SELECT * FROM tag WHERE name = '#{tag_name}'", true
        if tag.nil? || tag.empty?
          tag = Taupe::Model::Tag.load
          tag.name = tag_name
          tag.save
        end

        query = "INSERT INTO bookmark_tag (bookmark_id, tag_id) VALUES (#{bookmark.bookmark_id}, #{tag.tag_id})"
        Taupe::Model::Tag.exec query
      end
    end

    puts 'Bookmark added successfully'
  end

  # Delete a bookmark from its id
  def _delete
    # Set id and cache key
    id = @options[:id]
    cache_key = nil #"bookmark_#{id}"

    # Retrieve bookmark object
    bookmark = Taupe::Model::Bookmark.load id, cache_key
    fail "Unknown bookmark ##{id}" if bookmark.empty?

    # Delete it
    Taupe::Model::Tag.exec "DELETE FROM bookmark_tag WHERE bookmark_id = #{bookmark.bookmark_id}"
    bookmark.delete

    puts 'Bookmark deleted successfully'
  end

  # List bookmarks
  def _list
    # Build query
    query = 'SELECT DISTINCT(bookmark.bookmark_id), bookmark.* FROM bookmark'

    if !@options[:tags].nil? && !@options[:tags].empty?
      query << ' LEFT JOIN bookmark_tag ON bookmark.bookmark_id = bookmark_tag.bookmark_id'
      query << ' LEFT JOIN tag ON tag.tag_id = bookmark_tag.tag_id'
      query << " WHERE tag.name IN (#{@options[:tags].map { |t| '\'' + t + '\''}.join(',')})"
    end

    # Fetch results
    results = Taupe::Model::Bookmark.fetch query

    # Print results
    puts "\n%s | %s | %s | %s\n%s" % ['id'.ljust(4), 'name'.rjust(4).ljust(25), 'url'.ljust(50), 'tags', '-' * 120]
    results.each do |bookmark|
      # Get tags
      query = "SELECT tag.* FROM tag LEFT JOIN bookmark_tag USING(tag_id) WHERE bookmark_tag.bookmark_id = #{bookmark.bookmark_id}"
      tags = Taupe::Model::Tag.fetch query

      # Print data
      puts '%s | %s | %s | %s' % [
        bookmark.bookmark_id.to_s.ljust(4),
        bookmark.name.to_s.rjust(4).ljust(25),
        bookmark.url.to_s.ljust(50),
        tags.map { |t| t.name }.join(', ')
      ]
    end
    puts "\n(#{results.length} bookmark#{results.length > 1 ? 's' : ''} found)\n\n"
  end

  # Init dabatase
  def _init
    # Set some specific properties
    props = {pkey: '', tag: '', bookmark: ''}
    case Taupe::Database.type
    when :postgresql
      props[:pkey] = 'serial not null primary key'
    when :mysql
      props[:pkey] = 'int not null auto_increment'
      props[:tag] = ', PRIMARY KEY (tag_id)'
      props[:bookmark] = ', PRIMARY KEY (bookmark_id)'
    when :sqlite
      props[:pkey] = 'integer primary key autoincrement'
    end

    # SQL queries
    queries = []
    queries << "DROP TABLE IF EXISTS tag;"
    queries << "DROP TABLE IF EXISTS bookmark;"
    queries << "DROP TABLE IF EXISTS bookmark_tag;"
    queries << "CREATE TABLE tag (tag_id #{props[:pkey]}, name text #{props[:tag]});"
    queries << "CREATE TABLE bookmark (bookmark_id #{props[:pkey]}, name text, url text #{props[:bookmark]});"
    queries << "CREATE TABLE bookmark_tag (bookmark_id integer not null, tag_id integer not null);"

    # Execute queries
    queries.each { |query| Taupe::Database.exec query }

    puts 'Database initialized successfully'
  end

  # Set some methods private
  private :_dispatch, :_add, :_delete, :_list, :_init
end

# Parse options

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: bookmarker.rb [options]"

  opts.on("--init", "Initialize the database") do |o|
    options[:action] = :init
  end

  opts.on("-a", "--add", "Add a bookmark") do |o|
    options[:action] = :add
  end

  opts.on("-d", "--delete", "Delete a bookmark") do |o|
    options[:action] = :delete
  end

  opts.on("-l", "--list", "List bookmarks") do |o|
    options[:action] = :list
  end

  opts.on("-u URL", "--url URL", "Bookmark url") do |o|
    options[:url] = o
  end

  opts.on("-n NAME", "--name NAME", "Bookmark name") do |o|
    options[:name] = o
  end

  opts.on("-i ID", "--id ID", Integer, "Bookmark id") do |o|
    options[:id] = o
  end

  opts.on("-t x,y,z", "--tags x,y,z", Array, "Tags") do |o|
    options[:tags] = o
  end

end.parse!

# Run the application
Bookmaker.new options
