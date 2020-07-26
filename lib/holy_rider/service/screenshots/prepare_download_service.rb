# frozen_string_literal: true

require 'pry-byebug'

module HolyRider
  module Service
    module Screenshots
      class PrepareDownloadService
        def initialize(threads:, token:)
          @threads = threads
          @token = token
        end

        def call
          @threads.each do |thread|
            HolyRider::Workers::ProcessScreenshotDownloadPrep.perform_async(thread, @token)
          end
        end
      end
    end
  end
end
