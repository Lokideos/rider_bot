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
            {
              id: thread['threadId'],
              date: thread['threadModifiedDate'],
              message_thread_name: thread['latestMessageEventDetail']['sender']['onlineId']
            }
          end

          binding.pry

          prepared_threads.each do |thread|
            player = Player.find(message_thread_name: thread[:message_thread_name])
            player.add_message_thread(
              MessageThread.new(message_thread_id: thread[:id], last_modified_date: thread[:date])
            )
          end
        end
      end
    end
  end
end
