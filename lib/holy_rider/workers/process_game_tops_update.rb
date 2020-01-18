# frozen_string_literal: true

module HolyRider
  module Workers
    class ProcessGameTopsUpdate
      include Sidekiq::Worker
      sidekiq_options queue: :commands, retry: 2, backtrace: 20

      # TODO: move logic to service and update only needed game tops
      def perform
        Game.update_all_progress_caches
      end
    end
  end
end
