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

              HolyRider::Workers::ProcessCommand.perform_async(@chat_id, command, message_type)
            end
          end
        end
      end
    end
  end
end
