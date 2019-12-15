# frozen_string_literal: true

module HolyRider
  module Workers
    class ProcessTrophyTopUpdate
      include Sidekiq::Worker
      sidekiq_options queue: :trophies, retry: 2, backtrace: 20

      def perform(player_id)
        HolyRider::Service::Watcher::UpdateTrophyTopService.new(player_id: player_id).call
      end
    end
  end
end
