# frozen_string_literal: true

module HolyRider
  module Workers
    class ProcessTrophiesList
      include Sidekiq::Worker
      sidekiq_options queue: :trophies, retry: 5, backtrace: 20

      def perform(player, game, trophy_service_id, initial)
        HolyRider::Service::Watcher::ProcessTrophiesListService.new(player, game, trophy_service_id,
                                                                    initial).call
      end
    end
  end
end
