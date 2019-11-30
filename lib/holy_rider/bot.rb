# frozen_string_literal: true

module HolyRider
  module Bot
    class << self
      def application
        Application.instance
      end
    end
  end
end
