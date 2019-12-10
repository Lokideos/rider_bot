# frozen_string_literal: true

module HolyRider
  module Service
    module Command
      class Find
        def initialize(command, message_type)
          @command = command
          @message_type = message_type
        end

        def call
          game_title = @command[@message_type]['text'].split(' ')[1..-1].join(' ')
          top = Game.top_game(game_title)
          return unless top

          title = "<a href='#{top[:game].icon_url}'>#{top[:game].title} #{top[:game].platform}</a>"
          game_top = HolyRider::Service::Bot::GameTopService.new(top: top).call

          [title, game_top]
        end
      end
    end
  end
end
