# frozen_string_literal: true

module HolyRider
  module Workers
    class ProcessTopUpdates
      include Sidekiq::Worker
      sidekiq_options queue: :trophies, retry: 5, backtrace: 20

      def perform
        Player.trophy_top_force_update
      end
    end
  end
end
