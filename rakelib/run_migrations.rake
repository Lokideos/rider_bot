namespace :db do
  desc "Run migrations"
  task :migrate, [:version] do |_task, args|
    Sequel.extension :migration

    database_url = CONFIGURATION.config[:database][:database_url] + "/holy_rider_#{ENV['RACK_ENV']}"
    version = args[:version].to_i if args[:version]

    Sequel.connect(database_url) do |db|
      Sequel::Migrator.run(db, "db/migrations", target: version)
    end
    Rake::Task['db:version'].execute
  end
end


