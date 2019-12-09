# frozen_string_literal: true

module HolyRider
  module Workers
    class InitialProcessTrophy
      include Sidekiq::Worker
      sidekiq_options queue: :initial_user_data_load, retry: 5, backtrace: 20

      def perform(player_id, trophy_id, trophy_earning_time, initial)
        HolyRider::Service::Watcher::SaveTrophyService.new(player_id, trophy_id,
                                                           trophy_earning_time, initial).call
      end
    end
  end
end
