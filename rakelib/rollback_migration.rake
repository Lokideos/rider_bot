require "sequel/core"

namespace :db do
  desc "Rollback migration"
  task :rollback, [:version] do |_task, args|
    Sequel.extension :migration

    database_url = CONFIGURATION.config[:database][:database_url] + "/holy_rider_#{ENV['RACK_ENV']}"
    args.with_defaults(:version => 0)

    Sequel.connect(database_url) do |db|
      Sequel::Migrator.run(db, "db/migrations", target: args.version.to_i)
    end
    Rake::Task['db:version'].execute
  end
end
