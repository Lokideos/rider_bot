# frozen_string_literal: true

module HolyRider
  module Workers
    class ProcessScreenshotDownload
      include Sidekiq::Worker
      sidekiq_options queue: :screenshots, retry: 5, backtrace: 20

      def perform(message, token, sender_name)
        HolyRider::Service::Screenshots::DownloadScreenshotService
          .new(message: message, token: token, sender_name: sender_name).call
      end
    end
  end
end
