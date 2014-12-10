# Taupe

[![Gem Version](https://badge.fury.io/rb/taupe.svg)](http://badge.fury.io/rb/taupe)
[![Build Status](https://travis-ci.org/pierre-lecocq/taupe.svg?branch=master)](https://travis-ci.org/pierre-lecocq/taupe)

## What is it?

**Taupe** is a simple and elegant database model manager.

It relies on several popular backends:

- *postgresql*, *mysql* or *sqlite* for database engines
- *memcached* or *redis* for cache engines

The main idea is to set a database connection, an optional cache connection and your models definitions.
That's it.

Then, you can query on the database connection or on your models directly. If a cache backend is defined, the data will be stored and retrieved faster than ever.

No fancy SQL DSL. Just pure SQL. Let's be braves and responsibles.

## Why developping it?

It was developped for two main pros:

- control
- power

I can hear you: "But for this, there are some very popular ORMs like *ActiveRecord* or *Sequel*, you #@$!&+ ! "

Yes.
But No.
Definitely.

Here are the main reasons:

- ORMs are too complex for a large percent of our everyday use projects
- ORMs do not give you the opportunity to write SQL and control your queries (no control, no power). Well, yes they do, but for this, they load so many unused classes that your application's performances are really affected.
- ORMs have limits on joins, sub-queries, CTEs (... etc) and this is frustrating when doing hard SQL work like statistics

## How to use it?

### Install

In order to install the Taupe library, simply install the corresponding gem with

    sudo gem install taupe

After that, you must have a few gems install on your system, depending on which backends you want to use

    # If you use PostgreSQL database
    sudo gem install pg

    # If you use MySQL database
    sudo gem install mysql2

    # If you use Sqlite database
    sudo gem install sqlite3

    # If you use Memcached
    sudo gem install memcached

    # If you use Redis
    sudo gem install redis

### Define a SQL backend

#### Postgresql (highly recommended)

    # Setup a postgresql database backend
    Taupe::Database.setup do
      type :postgresql
      host :localhost
      username :myuser
      password :myfuckingstrongpassword
      database :mydatabase
    end

#### MySQL (not recommended)

    # Setup a mysql database backend
    Taupe::Database.setup do
      type :mysql
      host :localhost
      username :myuser
      password :myfuckingstrongpassword
      database :mydatabase
    end

#### SQLite

    # Setup a sqlite database backend
    Taupe::Database.setup do
      type :sqlite
      database File.expand_path('/tmp/mydatabase.db')
    end

### Optionally define a cache backend (recommended)

#### Memcached

    # Setup a memcached cache backend
    Taupe::Cache.setup do
      type :memcached
      host :localhost
      port 11211 # A symbol can not start with an integer, so make it an integer
    end

#### Redis

    # Setup a redis cache backend
    Taupe::Cache.setup do
      type :redis
      host :localhost
      port 6379 # A symbol can not start with an integer, so make it an integer
    end

### Define some models

    # Setup a model
    Taupe::Model.setup do
      table :article
      column :article_id, { type: Integer, :primary_key => true }
      column :title,      { type: String, :null => false }
      column :content,    { type: String }
      column :state,      { type: Integer }
      column :creation,   { type: Date, :locked => true }
    end

### And then? What can I do?

#### Load a new model object

    article = Taupe::Model::Article.load

#### Load an existing model object

    # A database ID
    article_id = 3

    # An optional cache key. Set it to nil if cache is not setted or needed
    cache_key = "article_#{article_id}"

    # Load model from database and create corresponding object
    article = Taupe::Model::Article.load article_id, cache_key

#### Save a modified model object

    # Modify the ruby object properties
    article.title = 'This is my modified article title'

    # Reflect changes in database/cache (insert or update)
    article.save

#### Execute raw queries

In order to execute raw queries like INERT, UPDATE or DELETE, the easiest method is to execute them directly on the database object. There is no specific need to execute them from a specific model's class.

    # Execute raw queries
    Taupe::Database.exec "INSERT INTO article (title, state) VALUES ('Another article', 1)"
    Taupe::Database.exec "UPDATE article SET title = 'Yet another article' WHERE article_id = 1"
    Taupe::Database.exec "DELETE article WHERE article_id = 1"

#### Fetching objects

There are two ways of fetching objects that depend on the expecting results

##### Fetch objects and get an Array of Hashes

By executing a SELECT query on the database object, Taupe returns an Array of the Hash values of the object.

For example:

    # Fetch results in an array
    articles = Taupe::Database.fetch "SELECT * FROM article"

gives:

    [
        { :article_id => 1, :title => 'An article'},
        { :article_id => 2, :title => 'Another article'}
    ]

This is great if you need either raw or flexible data to deal with afterwards.
Of course, you deal with this data like any ruby array of hashes.

##### Fetch objects and get an Array of Model Objects

By executing a SELECT query on a specific model object, Taupe returns an Array of Objects.

For example:

    # Fetch
    articles = Taupe::Model::Article.fetch "SELECT * FROM article"

gives (these are dummy data):

    [
        <Taupe::Model::Article:0x000000014e3c88 @_table=:article, @_columns={:article_id=>{:type=>Integer, :primary_key=>true}, # skip...
        <Taupe::Model::Article:0x000000014e38b8 @_table=:article, @_columns={:article_id=>{:type=>Integer, :primary_key=>true} # skip...
    ]

Therefore, it allows you to deal with all the objects contained in the result array like (for example):

    articles.each do |article|
        # Display some properties
        puts article.article_id
        puts "The title of this article is: #{article.title}"

        # Modify some properties
        article.title = '[Updated] ' + article.title

        # And save the model
        article.save
    end

And this methods allows you to play with extended models like described just below.

#### Extend models

Models can be extended to add some properties that are not stored (and will not be stored) in the database.

Let's take an example to illustrate this, instead of talking:

    module Taupe
      class Model
        class Article

          def full_title
            add_property :full_title, "Article #{article_id} - #{title}"
          end

          def tag_ids
            add_property :tag_ids, [1, 2, 5]
          end
        end
      end
    end

This adds two new dummy properties that can be uesd as any other property:

    articles = Taupe::Model::Article.fetch "SELECT * FROM article"

    articles.each do |r|
      puts r.full_title
    end

## License

Please see the [LICENSE](https://github.com/pierre-lecocq/taupe/blob/master/LICENSE) file
