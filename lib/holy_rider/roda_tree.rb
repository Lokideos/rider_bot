# frozen_string_literal: true

module HolyRider
  class RodaTree < Roda
    plugin(:not_found) { { error: 'Not found' } }

    route do |r|
      r.root do
        'asasd'
      end

      r.on 'welcome' do
        'hello world'
      end

      r.on 'favicon.ico' do
        '?'
      end
    end
  end
end
