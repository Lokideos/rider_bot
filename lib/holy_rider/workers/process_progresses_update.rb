# frozen_string_literal: true

module HolyRider
  module Workers
    class ProcessProgressesUpdate
      include Sidekiq::Worker
      sidekiq_options queue: :trophies, retry: 5, backtrace: 20

      def perform(game_id)
        HolyRider::Service::Watcher::UpdateGameProgressesService.new(game_id: game_id).call
      end
    end
  end
end
