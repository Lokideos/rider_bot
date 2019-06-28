namespace :db do
  desc 'Create database'
  task :create do
    Sequel.connect(CONFIGURATION.config[:database][:database_url]) do |db|
      CONFIGURATION.config[:database][:names].each do |name|
        db.execute "CREATE DATABASE #{name}"
      end
    end
  end
end
