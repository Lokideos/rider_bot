namespace :db do
  desc "Prints current schema version"
  task :version do
    Sequel.extension :migration

    database_url = CONFIGURATION.config[:database][:database_url] + "/holy_rider_#{ENV['RACK_ENV']}"

    version = if Sequel.connect(database_url).tables.include?(:schema_info)
                Sequel.connect(database_url)[:schema_info].first[:version]
              end || 0

    puts "Schema Version: #{version}"
  end
end