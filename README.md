# Taupe

## Disclamer

Work in progress !

### TODO

- Finish live tests with sample app
- Finish rspec tests
- Gemify and post to rubygems.org

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

### Prerequisites

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
      port :11211
    end

#### Redis

    # Setup a redis cache backend
    Taupe::Cache.setup do
      type :redis
      host :localhost
      port :6379
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

#### Query, query, query. But by yourself.

    # Execute a single query
    Taupe::Database.exec "INSERT INTO article (title, state) VALUES ('Another article', 1)"

    # Fetch results in an array
    articles = Taupe::Database.fetch "SELECT * FROM article"

    # Fetch a single result
    article = Taupe::Database.fetch "SELECT * FROM article WHERE article_id = 3", true

For more clarity, you can also exec or fetch from any model class. It is exactly the same.

    # Execute an insert query
    Taupe::Model::Article.exec "INSERT INTO article (title, state) VALUES ('Another article', 1)"

    # Fetch
    articles = Taupe::Model::Article.fetch "SELECT * FROM article"

    # Fetch single
    article = Taupe::Model::Article.fetch "SELECT * FROM article WHERE article_id = 3", true

## License

Please see the [LICENSE](https://github.com/pierre-lecocq/taupe/blob/master/LICENSE) file
