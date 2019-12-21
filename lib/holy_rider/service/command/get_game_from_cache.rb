# frozen_string_literal: true

module HolyRider
  module Service
    module Command
      class GetGameFromCache
        def initialize(command, message_type)
          @command = command
          @message_type = message_type
        end

        def call
          index = @command[@message_type]['text'].split(' ')[0].split('@')[0][1..-1]
          player = @command['message']['from']['username']
          cached_top = Game.find_game_from_cache(player, index)
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
