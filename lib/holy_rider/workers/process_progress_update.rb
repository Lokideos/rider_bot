# frozen_string_literal: true

module HolyRider
  module Workers
    class ProcessProgressUpdate
      include Sidekiq::Worker
      sidekiq_options queue: :trophies, retry: 5, backtrace: 20

      def perform(game_acquisition_id)
        HolyRider::Service::Watcher::UpdateGameProgressService.new(game_acquisition_id: game_acquisition_id).call
      end
    end
  end
end
