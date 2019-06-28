# frozen_string_literal: true

require 'singleton'
require 'yaml'
require 'sequel/core'

module HolyRider
  class Configuration
    include Singleton

    attr_reader :config

    def initialize
      @config = {}
      load_configuration
    end

    def load_configuration
      load_database
      generate_database_url
    end

    def load_database
      database_config = YAML.load_file(File.join(__dir__, '../../', 'config', 'database.yml'))
      @config[:database] = {
        db_config: database_config['default'],
        user: database_config['default']['username'],
        password: database_config['default']['password'],
        host: database_config['default']['host'],
        port: database_config['default']['port'],
        names: database_config.values[1..-1].map { |config| config['database'] }
      }
    end

    def generate_database_url
      @config[:database][:database_url] = "postgres://#{config[:database][:user]}:" \
        "#{config[:database][:password]}@#{config[:database][:host]}:#{config[:database][:port]}"
    end
  end
end
