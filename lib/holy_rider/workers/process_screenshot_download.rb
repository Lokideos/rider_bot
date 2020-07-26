# frozen_string_literal: true

module HolyRider
  module Workers
    class ProcessScreenshotDownload
      include Sidekiq::Worker
      sidekiq_options queue: :screenshots, retry: 5, backtrace: 20

      def perform(message, token)
        HolyRider::Service::Screenshots::DownloadScreenshotService
          .new(message: message, token: token).call
      end
    end
  end
end
