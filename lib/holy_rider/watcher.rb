# frozen_string_literal: true

module HolyRider
  module Watcher
    class << self
      def application
        Application.instance
      end
    end
  end
end
