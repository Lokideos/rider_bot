# frozen_string_literal: true

module HolyRider
  module Service
    module Watcher
      class SaveTrophyService
        PLATINUM_STICKER = 'BQADAgADTwsAAkKvaQABElnJclGri9EC'

        def initialize(player_id, trophy_id, trophy_earning_time, initial)
          @player = Player.find(id: player_id)
          @trophy = Trophy.find(id: trophy_id)
          @trophy_earning_time = trophy_earning_time
          @initial = initial
        end

        def call
          # TODO: add service to also add earned date to join table via transaction
          @player.add_trophy(@trophy)
          trophy_acquisition = @player.reload.trophy_acquisitions.find do |acquisition|
            acquisition.trophy_id == @trophy.id
          end
          trophy_acquisition.update(earned_at: @trophy_earning_time)
          return if @initial

          HolyRider::Workers::ProcessTrophyTopUpdate.perform_async(@player.id, @trophy.id)

          # TODO: probably should use ruby built-in url generators for this
          link = prepared_link
          message_parts = @player.trophy_ping_on? ? ["@#{@player.telegram_username}"] : ['<code>' \
            "#{@player.telegram_username}</code>"]
          message_parts << "- <a href='#{link}'>#{@trophy.game.title} #{@trophy.game.platform}</a>"

          message = message_parts.join(' ')
          HolyRider::Service::Bot::SendChatMessageService.new(chat_id: ENV['PS_CHAT_ID'],
                                                              message: message).call
          return unless @trophy.trophy_type == 'platinum'

          HolyRider::Service::Bot::SendStickerService.new(chat_id: ENV['PS_CHAT_ID'],
                                                          sticker: PLATINUM_STICKER).call
        end

        private

        # TODO: refactoring needed
        def prepared_link
          "http://#{ENV['FQDN']}/trophy?" \
            "player_account=#{CGI.escape(@player.trophy_account)}&" \
            "trophy_title=#{CGI.escape(@trophy.trophy_name)}&" \
            "trophy_description=#{CGI.escape(@trophy.trophy_description)}&" \
            "trophy_type=#{CGI.escape(@trophy.trophy_type)}&" \
            "trophy_rarity=#{CGI.escape(@trophy.trophy_earned_rate)}%&" \
            "icon_url=#{CGI.escape(@trophy.trophy_icon_url)}&" \
            "game_title=#{CGI.escape(@trophy.game.title)}"
        end
      end
    end
  end
end
