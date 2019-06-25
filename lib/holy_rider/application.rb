# frozen_string_literal: true

require 'roda'
require 'yaml'
require 'sequel'
require 'singleton'
require_relative 'roda_tree'

module HolyRider
  class Application
    include Singleton

    attr_reader :db

    def initialize
      @db = nil
    end

    def bootstrap!
      setup_database
      setup_routing_tree
    end

    def call(env)
      RodaTree.call(env)
    end

    def setup_database
      database_config = YAML.load_file(HolyRider.root.join('config/database.yml'))

      @db = Sequel.connect(generate_db_url(database_config))
    end

    def setup_routing_tree
      return RodaTree.freeze.app if ENV['RACK_ENV'] == 'production'

      RodaTree.app
    end

    private

    def generate_db_url(db_config)
      config = db_config['default']
      database_names = db_config.keys
      index = database_names.find_index(ENV['RACK_ENV'])
      database = database_names[index]

      "postgres://#{config['username']}:#{config['password']}@#{config['host']}:#{config['port']}/#{database}"
    end
  end
end
