# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HolyRider::Workers::ProcessTrophyRarityUpdate do
  let(:game) do
    Fabricate(:game) do
      trophies do
        [
          Fabricate(:trophy, trophy_name: 'requested_trophy', trophy_service_id: 1),
          Fabricate(:trophy, trophy_name: 'not_requested_trophy', trophy_service_id: 2)
        ]
      end
    end
  end
  let(:requested_trophy) { game.trophies.first }
  let(:not_requested_trophy) { game.trophies.last }
  let(:trophy_data) do
    {
      'trophy_service_id' => 1,
      'trophy_earned_rate' => 10.4,
      'trophy_rare' => 2
    }
  end
  let(:service) { HolyRider::Service::Watcher::UpdateTrophyRarityService }
  let(:service_object) { double('UpdateTrophyRarityService.new') }

  it { is_expected.to be_processed_in :trophies }
  it { is_expected.to be_retryable 5 }
  it { is_expected.to save_backtrace 20 }

  describe '#perform' do
    before do
      allow(service).to receive(:new).and_return(service_object)
      allow(service_object).to receive(:call)
    end

    it 'should create service object with requested trophy' do
      expect(service).to receive(:new).with(requested_trophy,
                                            trophy_data['trophy_earned_rate'],
                                            trophy_data['trophy_rare'])

      subject.perform(game.id, trophy_data)
    end

    it 'should not create service object with not requested trophy' do
      expect(service).to_not receive(:new).with(not_requested_trophy,
                                                trophy_data['trophy_earned_rate'],
                                                trophy_data['trophy_rare'])

      subject.perform(game.id, trophy_data)
    end

    it 'should call UpdateTrophyRarityService service' do
      expect(service_object).to receive(:call)

      subject.perform(game.id, trophy_data)
    end
  end
end
