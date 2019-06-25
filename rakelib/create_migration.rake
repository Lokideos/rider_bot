namespace :db do
  desc 'Create database migration'
  task :create_migration, [:name] do |_task, args|
    database_config = YAML.load_file(File.join(__dir__, '../', 'config', 'database.yml'))
    db_config = database_config['default']
    user = db_config['username']
    password = db_config['password']
    host = db_config['host']
    port = db_config['port']
    database_url = "postgres://#{user}:#{password}@#{host}:#{port}/holy_rider_#{ENV['RACK_ENV']}"

    ENV['RACK_ENV'] = 'development' unless ENV['RACK_ENV']
    Sequel.extension :migration

    version = if Sequel.connect(database_url).tables.include?(:schema_info)
                Sequel.connect(database_url)[:schema_info].first[:version]
              end || 0

    filepath = File.join(__dir__, '../', 'db', 'migrations', "#{version + 1}_#{args.name}.rb")
    migration_boilerplate = "# frozen_string_literal: true\n\n" +
      "Sequel.migration do\n  up do\n\n  end\n\n  down do\n\n  end\nend"
    File.write(filepath, migration_boilerplate)
  end
end