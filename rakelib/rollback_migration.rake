require "sequel/core"

namespace :db do
  desc "Rollback migration"
  task :rollback, [:version] do |_task, args|
    database_config = YAML.load_file(File.join(__dir__, '../', 'config', 'database.yml'))
    db_config = database_config['default']
    user = db_config['username']
    password = db_config['password']
    host = db_config['host']
    port = db_config['port']

    args.with_defaults(:version => 0)
    Sequel.extension :migration
    Sequel.connect("postgres://#{user}:#{password}@#{host}:#{port}/holy_rider_#{ENV['RACK_ENV']}") do |db|
      Sequel::Migrator.run(db, "db/migrations", target: args[:target].to_i)
    end
  end
end
