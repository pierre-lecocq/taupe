# Taupe

## Disclamer

Work in progress !

### TODO

- Fix the "last_id" method in PG driver
- Implement escaping methods in SQL drivers
- Implement auto-schema discovery methods
- Improve validators
- Finish live tests with sample app
- Finish rspec tests
- Gemify and post to rubygems.org

Will be done and finished in the coming month.

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

### Define a SQL backend

#### Postgresql (a.k.a "highly recommended")

    Taupe::Database.setup do
      type :postgresql
      host :localhost
      username :myuser
      password :myfuckingstrongpassword
      database :mydatabase
    end

#### MySQL (a.k.a "absolutely not recommended, unless you did not discover life, yet")

    Taupe::Database.setup do
      type :mysql
      host :localhost
      username :myuser
      password :myfuckingstrongpassword
      database :mydatabase
    end

#### SQLite (a.k.a "what the ...?? Well, in this specific case, Mmmmm'Okay.")

    Taupe::Database.setup do
      type :sqlite
      database File.expand_path('/tmp/mydatabase.db')
    end

### Optionally define a cache backend (recommended, without any kind of humour)

#### Memcached

    Taupe::Cache.setup do
      type :memcached
      host :localhost
      port :11211
    end

#### Redis

    Taupe::Cache.setup do
      type :redis
      host :localhost
      port :6379
    end

### Define some models

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

    article_id = 3 # A database ID
    cache_key = "article_#{article_id}" # an optional cache key. Set it to nil if cache is not needed

    article = Taupe::Model::Article.load article_id, cache_key

#### Save a modified model object

     article.title = 'This is my modified article title'

     article.save # Insert or update the databse according to the way the article object was loaded (new one or existing one)

#### Query, query, query. But by yourself.

    # Execute a single query
    Taupe::Database.exec "INSERT INTO article (title, state) VALUES ('Another article', 1)"

    # Fetch results in an array
    articles = Taupe::Database.fetch "SELECT * FROM article"

    # Fetch on result
    article = Taupe::Database.fetch "SELECT * FROM article WHERE article_id = 3", true

For more clarity, you can also exec or fetch from any model class. It is exactly the same.

    Taupe::Model::Article.exec "INSERT INTO article (title, state) VALUES ('Another article', 1)"
    articles = Taupe::Model::Article.fetch "SELECT * FROM article"
    article = Taupe::Model::Article.fetch "SELECT * FROM article WHERE article_id = 3", true

## What is that lame name? "Taupe"?

Because "Taupe::Model" ... a (really) bad french pun. Nevermind. Won't explain. Really.
