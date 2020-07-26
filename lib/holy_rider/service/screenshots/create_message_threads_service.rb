# frozen_string_literal: true

module HolyRider
  module Service
    module Screenshots
      class CreateMessageThreadsService
        def initialize(message_threads:)
          @message_threads = message_threads
        end

        def call
          prepared_threads = @message_threads.map do |thread|
            { id: thread['threadId'], date: thread['threadModifiedDate'] }
          end

          prepared_threads.each do |thread|
            MessageThread.create(message_thread_id: thread[:id], last_modified_date: thread[:date])
          end
        end
      end
    end
  end
end
