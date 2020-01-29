# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HolyRider::Service::Watcher::UpdateTrophyRarityService do
  let(:trophy) { Fabricate(:trophy, trophy_rare: 1, trophy_earned_rate: '5.0') }
  let(:new_trophy_earned_rate) { '10.0' }
  let(:new_trophy_rare) { 2 }

  subject do
    HolyRider::Service::Watcher::UpdateTrophyRarityService.new(trophy,
                                                               new_trophy_earned_rate,
                                                               new_trophy_rare)
  end

  it 'should update trophy with new trophy earned rate' do
    subject.call

    expect(trophy.trophy_earned_rate).to eq new_trophy_earned_rate
  end

  it 'should update trophy with new trophy rare' do
    subject.call

    expect(trophy.trophy_rare).to eq new_trophy_rare
  end
end
