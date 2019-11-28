# frozen_string_literal: true

require_relative 'bot/application'

module HolyRider
  module Bot
    class << self
      def application
        Application.instance
      end
    end
  end
end
