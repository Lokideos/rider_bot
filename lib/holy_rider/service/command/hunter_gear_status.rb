# frozen_string_literal: true

module HolyRider
  module Service
    module Command
      class HunterGearStatus
        def initialize(command, message_type)
          @command = command
          @message_type = message_type
        end

        def call
          name = @command[@message_type]['text'].split(' ')[1]
          message = TrophyHunter.find(name: name)&.geared_up?

          [message]
        end
      end
    end
  end
end
