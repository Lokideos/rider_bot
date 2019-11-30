# frozen_string_literal: true

module HolyRider
  module Bot
    class Application
      include Singleton

      MESSAGE_TYPES = %w[message edited_message].freeze

      attr_reader :db, :redis

      def initialize
        @db = HolyRider::Application.instance.db
        @redis = HolyRider::Application.instance.redis
        @chat_updates_service = HolyRider::Service::Bot::ChatUpdateService
        clear_last_processed_message
        bot_loop
      end

      def bot_loop
        loop do
          new_messages = chat_updates

          unless new_messages.any?
            p 'No updates'
            next
          end

          HolyRider::Service::Bot::ProcessCommandService.new(commands(new_messages)).call
          HolyRider::Service::Bot::ProcessMentionService.new(mentions(new_messages)).call

          store_last_processed_message(new_messages.last['update_id'])

          p 'End of iteration'
        end
      end

      private

      def commands(messages)
        MESSAGE_TYPES.flat_map do |message_type|
          select_messages_by_type(messages, message_type, 'bot_command')
        end
      end

      def mentions(messages)
        MESSAGE_TYPES.flat_map do |message_type|
          select_messages_by_type(messages, message_type, 'mention')
        end
      end

      def select_messages_by_type(messages, type, entity_type)
        messages.select do |message|
          message.dig(type, 'entities')&.any? { |entity| entity['type'] == entity_type }
        end
      end

      def store_last_processed_message(update_id)
        @redis.set('holy_rider:bot:chat:last_processed_message_id', update_id)
      end

      def last_processed_message_id
        @redis.get('holy_rider:bot:chat:last_processed_message_id').to_i
      end

      def clear_last_processed_message
        @redis.del('holy_rider:bot:chat:last_processed_message_id')
      end

      def chat_updates
        all_recent_messages = @chat_updates_service.new.call['result']
        unless last_processed_message_id.zero?
          return all_recent_messages.select do |message|
            message['update_id'] > last_processed_message_id
          end
        end

        store_last_processed_message(all_recent_messages.last['update_id'])
        []
      end
    end
  end
end
