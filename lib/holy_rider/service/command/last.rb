# frozen_string_literal: true

module HolyRider
  module Service
    module Command
      class Last
        def initialize(command, message_type)
          @command = command
          @message_type = message_type
        end

        def call
          cached_top = Game.find_last_game
          return unless cached_top

          top = Oj.load(cached_top, {})
          title = "<a href='#{top[:game][:icon_url]}'>" \
                  "#{top[:game][:title]} #{top[:game][:platform]}</a>"
          game_top = HolyRider::Service::Bot::GameTopService.new(top: top[:progresses]).call

          [title, game_top]
        end
      end
    end
  end
end
