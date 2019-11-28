# frozen_string_literal: true

require 'singleton'
require_relative '../service/bot/chat_update_service'
require_relative '../service/bot/send_chat_message_service'
require_relative '../service/bot/process_command_service'
require_relative '../service/bot/process_mention_service'

module HolyRider
  module Bot
    class Application
      include Singleton

      MESSAGE_TYPES = %w[message edited_message].freeze

      attr_reader :db, :redis

      def initialize
        @db = HolyRider::Application.instance.db
        @redis = HolyRider::Application.instance.redis
        clear_last_processed_message
        bot_loop
      end

      def bot_loop
        loop do
          chat_updates = get_chat_updates

          unless chat_updates.any?
            p 'No updates'
            next
          end

          commands = get_commands(chat_updates)
          mentions = get_mentions(chat_updates)

          HolyRider::Service::Bot::ProcessCommandService.new(commands).call
          HolyRider::Service::Bot::ProcessMentionService.new(mentions).call

          set_last_processed_message(chat_updates.last['update_id'])

          p 'End of iteration'
        end
      end

      private

      def get_commands(messages)
        MESSAGE_TYPES.flat_map do |message_type|
          select_messages_by_type(messages, message_type, 'bot_command')
        end
      end

      def get_mentions(messages)
        MESSAGE_TYPES.flat_map do |message_type|
          select_messages_by_type(messages, message_type, 'mention')
        end
      end

      def select_messages_by_type(messages, type, entity_type)
        messages.select do |message|
          message.key?(type) && message[type]['entities']&.any? do |entity|
            entity['type'] == entity_type
          end
        end
      end

      def set_last_processed_message(update_id)
        @redis.set('holy_rider:bot:chat:last_processed_message_id', update_id)
      end

      def last_processed_message_id
        @redis.get('holy_rider:bot:chat:last_processed_message_id').to_i
      end

      def clear_last_processed_message
        @redis.del('holy_rider:bot:chat:last_processed_message_id')
      end

      def get_chat_updates
        all_chat_updates = @chat_updates_service.new.call['result']
        unless last_processed_message_id.zero?
          return all_chat_updates.select do |message|
            message['update_id'] > last_processed_message_id
          end
        end

        all_chat_updates.select do |message|
          message['message']['date'] >= Time.now.to_i
        end
      end
    end
  end
end
