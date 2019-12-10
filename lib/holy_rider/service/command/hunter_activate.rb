# frozen_string_literal: true

module HolyRider
  module Service
    module Command
      class HunterActivate
        def initialize(command, message_type)
          @command = command
          @message_type = message_type
        end

        def call
          name = @command[@message_type]['text'].split(' ')[1]
          trophy_hunter = TrophyHunter.find(name: name)
          trophy_hunter.activate

          ["#{name} активирован"] if trophy_hunter.active?
        end
      end
    end
  end
end
