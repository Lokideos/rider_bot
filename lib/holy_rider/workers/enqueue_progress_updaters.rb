# frozen_string_literal: true

module HolyRider
  module Workers
    class EnqueueProgressUpdaters
      include Sidekiq::Worker
      sidekiq_options queue: :trophies, retry: 5, backtrace: 20

      def perform(game_id, checked_player_id)
        GameAcquisition.where(game_id: game_id)
                       .exclude(player_id: checked_player_id).map(:id).each do |game_acquisition_id|
          HolyRider::Worker::ProcessProgressUpdate.perform_async(game_acquisition_id)
        end
      end
    end
  end
end
