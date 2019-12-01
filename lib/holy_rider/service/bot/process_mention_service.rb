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

              HolyRider::Workers::ProcessMention.perform_async(@chat_id, mention, message_type)
            end
          end
        end
      end
    end
  end
end
