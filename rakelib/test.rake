# frozen_string_literal: true

namespace :test do
  desc "run"
  task run: :environment do
    cmd = "rake parallel:spec[3]"
    puts "Running rspec via `#{cmd}`"

    start = Time.now
    system(cmd)
    finish = Time.now

    puts "Total time is #{finish - start}"
  end
end