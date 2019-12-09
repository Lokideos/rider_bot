# frozen_string_literal: true

module HolyRider
  module Workers
    class InitialProcessTrophiesList
      include Sidekiq::Worker
      sidekiq_options queue: :initial_user_data_load, retry: 5, backtrace: 20

      def perform(player, game, trophy_service_id, initial)
        HolyRider::Service::Watcher::ProcessTrophiesListService.new(player, game, trophy_service_id,
                                                                    initial).call
      end
    end
  end
end
