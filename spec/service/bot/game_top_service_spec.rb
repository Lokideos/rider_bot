# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HolyRider::Service::Bot::GameTopService do
  # not testing view related logic
  let(:platinum_trophy_icon) { "\xF0\x9F\x8F\x86" }
  let(:progress_with_platinum_trophy) do
    {
      trophy_account: 'trophy_account',
      progress: '10',
      platinum_earning_date: 'some_date'
    }
  end
  let(:progress_without_platinum_trophy) do
    {
      trophy_account: 'trophy_account',
      progress: '10'
    }
  end
  let(:progress_with_big_name) do
    {
      trophy_account: 'extremly_large_name',
      progress: '10'
    }
  end
  let(:top_with_platinum_trophy) { [progress_with_platinum_trophy] }
  let(:top_without_platinum_trophy) { [progress_without_platinum_trophy] }
  let(:top_with_big_name) { [progress_with_big_name] }

  context 'with top with platinum trophy' do
    subject { HolyRider::Service::Bot::GameTopService.new(top: top_with_platinum_trophy) }

    it 'should return String' do
      expect(subject.call).to be_a String
    end

    it 'should include platinum trophy icon' do
      expect(subject.call).to include(platinum_trophy_icon)
    end
  end

  context 'with top without platinum trophy' do
    subject { HolyRider::Service::Bot::GameTopService.new(top: top_without_platinum_trophy) }

    it 'should return String' do
      expect(subject.call).to be_a String
    end

    it 'should not include platinum trophy icon' do
      expect(subject.call).to_not include(platinum_trophy_icon)
    end
  end

  context 'with names with big length' do
    subject { HolyRider::Service::Bot::GameTopService.new(top: top_with_big_name) }

    it 'should replace last player name characters with .. if its length > 12' do
      shortened_name = top_with_big_name.first[:trophy_account][0..12] + '..'

      expect(subject.call).to include(shortened_name)
    end
  end
end
