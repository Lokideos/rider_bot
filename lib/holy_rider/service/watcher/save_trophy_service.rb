# frozen_string_literal: true

module HolyRider
  module Service
    module Watcher
      class SaveTrophyService
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

          message = "#{@player.telegram_username} earned trophy #{@trophy.trophy_name}!"
          HolyRider::Service::Bot::SendChatMessageService.new(chat_id: ENV['PS_CHAT_ID'],
                                                              message: message).call
        end
      end
    end
  end
end
