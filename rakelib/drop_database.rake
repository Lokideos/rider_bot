require 'sequel'
require 'yaml'

namespace :db do
  desc 'Drop database'
  task :drop do
    database_config = YAML.load_file(File.join(__dir__, '../', 'config', 'database.yml'))
    db_config = database_config['default']
    user = db_config['username']
    password = db_config['password']
    host = db_config['host']
    port = db_config['port']
    names = database_config.values[1..-1].map { |config| config['database'] }
    database_url = "postgres://#{user}:#{password}@#{host}:#{port}"
    Sequel.connect(database_url) do |db|
      names.each do |name|
        db.execute "DROP DATABASE #{name}"
      end
    end
  end
end