# frozen_string_literal: true

Fabricator(:game) do
  trophy_service_id { sequence { |n| "trophy_service_id_#{n}" } }
  title { sequence { |n| "game_title_#{n}" } }
  platform { 'PS4' }
  icon_url { 'url_to_icon' }
end
