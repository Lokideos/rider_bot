# frozen_string_literal: true

require 'sidekiq/web'

module HolyRider
  class RodaTree < Roda
    plugin(:not_found) { { error: 'Not found' } }
    plugin :hooks
    plugin :render, engine: 'slim', views: 'lib/holy_rider/views/roda'

    route do |r|
      r.root do
        '<h1>The RODA root</h1>'
      end

      r.on 'trophy' do
        params = request.params

        render('trophy', locals: {
                 psn_id: params['player_account'],
                 trophy_title: params['trophy_title'],
                 trophy_description: params['trophy_description'],
                 trophy_type: params['trophy_type'],
                 trophy_rarity: params['trophy_rarity'],
                 trophy_icon_url: params['icon_url'],
                 game_title: params['game_title']
               })
      end

      r.redirect('/') unless request.params['access_token'] == ENV['ACCESS_TOKEN']

      r.on 'sidekiq' do
        r.run Sidekiq::Web
      end

      r.on 'welcome' do
        'hello world'
      end

      r.on 'favicon.ico' do
        '?'
      end

      # TODO: delete telegram routes before release
      r.on 'get_updates' do
        HolyRider::Service::Bot::ChatUpdateService.new.call.to_json
      end

      r.on 'send_message' do
        HolyRider::Service::Bot::SendChatMessageService.new(chat_id: ENV['PS_CHAT_ID'],
                                                            message: 'Test').call.to_json
      end
    end
  end
end
