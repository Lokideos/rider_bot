# frozen_string_literal: true

module HolyRider
  module Service
    module Bot
      class ProcessCommandService
        def initialize(commands)
          @commands = commands
          @chat_id = ENV['PS_CHAT_ID']
        end

        def call
          @commands.each do |command|
            HolyRider::Bot::Application::MESSAGE_TYPES.each do |message_type|
              next unless command.key? message_type

              case command[message_type]['text']
              when '/help'
                HolyRider::Service::Bot::SendChatMessageService.new(chat_id: @chat_id,
                                                                    message: 'Список команд:').call
              end
            end
          end
        end
      end
    end
  end
end
