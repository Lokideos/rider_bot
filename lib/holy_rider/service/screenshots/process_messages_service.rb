# frozen_string_literal: true

module HolyRider
  module Service
    module Screenshots
      class ProcessMessagesService
        def initialize(message_thread:, token:)
          @message_thread = message_thread
          @token = token
          @messages_client = HolyRider::Client::PSN::Messages::GetMessages
        end

        def call
          db_thread = MessageThread.find(message_thread_id: @message_thread['threadId'])
          messages = @messages_client.new(thread_id: @message_thread['threadId'],
                                          token: @token).request_message_list
          last_processed_message = messages.find do |message|
            message['messageEventDetail']['eventIndex'] == db_thread.last_message_index
          end
          last_message_index = messages.index(last_processed_message)
          new_messages = messages[0..last_message_index&.-(1)]
          image_messages = new_messages.select do |message|
            message['messageEventDetail']['eventCategoryCode'] == 3
          end

          image_messages.each do |message|
            HolyRider::Workers::ProcessScreenshotDownload.perform_async(message, @token)
          end

          db_thread.update(last_message_index: messages[0]['messageEventDetail']['eventIndex'])
        end
      end
    end
  end
end
