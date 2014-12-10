# File: taupe.gemspec
# Time-stamp: <2014-12-10 14:47:44 pierre>
# Copyright (C) 2014 Pierre Lecocq
# Description: Taupe library gemspec file

require File.expand_path('../lib/taupe', __FILE__)

Gem::Specification.new do |gem|
  gem.name              = 'taupe'
  gem.require_paths     = ['lib']
  gem.version           = Taupe::VERSION
  gem.files             =
    %w(README.md Gemfile Rakefile LICENSE taupe.gemspec .rubocop.yml) +
    `git ls-files lib spec`.split("\n")

  gem.authors           = ['Pierre Lecocq']
  gem.email             = ['pierre.lecocq@gmail.com']
  gem.summary           = 'A model manager with database and cache backends in ruby'
  gem.description       = 'Access to your database and cache backends easily in ruby'
  gem.homepage          = 'https://github.com/pierre-lecocq/taupe'
  gem.date              = '2014-08-01'
end
