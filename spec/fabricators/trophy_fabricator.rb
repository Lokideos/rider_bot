# frozen_string_literal: true

Fabricator(:trophy) do
  game
  trophy_service_id { sequence { |n| n } }
  trophy_name { sequence { |n| "trophy_name_#{n}" } }
  trophy_description { sequence { |n| "trophy_description_#{n}" } }
  trophy_type { 'gold' }
  trophy_icon_url { 'url_to_trophy_icon' }
  trophy_small_icon_url { 'url_to_small_trophy_icon' }
  trophy_earned_rate { 10.5 }
  trophy_rare { 1 }
  hidden { false }
end
