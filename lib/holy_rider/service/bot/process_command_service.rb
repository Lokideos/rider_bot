# frozen_string_literal: true

module HolyRider
  module Service
    module Bot
      class ProcessCommandService
        def initialize(commands)
          @commands = commands
        end

        def call
          @commands.each do |command|
            HolyRider::Bot::Application::MESSAGE_TYPES.each do |message_type|
              next unless command.key? message_type

              HolyRider::Workers::ProcessCommand.perform_async(command, message_type)
            end
          end
        end
      end
    end
  end
end
