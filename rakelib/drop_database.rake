namespace :db do
  desc 'Drop database'
  task :drop do
    Sequel.connect(CONFIGURATION.config[:database][:database_url]) do |db|
      CONFIGURATION.config[:database][:names].each do |name|
        db.execute "DROP DATABASE #{name}"
      end
    end
  end
end