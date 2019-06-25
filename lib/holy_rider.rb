# frozen_string_literal: true

require 'pathname'
require_relative 'holy_rider/application'

module HolyRider
  class << self
    def application
      Application.instance
    end

    def root
      Pathname.new(File.expand_path('..', __dir__))
    end
  end
end
