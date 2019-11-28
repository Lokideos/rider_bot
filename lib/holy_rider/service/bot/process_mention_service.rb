# frozen_string_literal: true

module HolyRider
  module Service
    module Bot
      class ProcessMentionService
        def initialize(mentions)
          @mentions = mentions
          @chat_id = ENV['PS_CHAT_ID']
        end

        def call
          @mentions.each do |mention|
            HolyRider::Bot::Application::MESSAGE_TYPES.each do |message_type|
              next unless mention.key? message_type

              if mention[message_type]['text'].include? 'привет'
                HolyRider::Service::Bot::SendChatMessageService.new(chat_id: @chat_id,
                                                                    message: 'Привет, Мастер.').call
              end
            end
          end
        end
      end
    end
  end
end
