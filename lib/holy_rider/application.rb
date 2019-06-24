# frozen_string_literal: true

require 'roda'

module HolyRider
  class Application < Roda
    def self.bootstrap!
      # setup database
    end

    plugin(:not_found) { { error: "Not found" } }

    route do |r|
      r.on 'welcome' do
        "hello world"
      end
    end
  end
end
