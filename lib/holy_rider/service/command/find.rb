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
          cached_top = Game.top_game(game_title)
          return ['Игра не найдена'] unless cached_top

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
