# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HolyRider::Workers::ProcessTrophyTopUpdate do
  let(:service) { HolyRider::Service::Watcher::UpdateTrophyTopService }
  let(:service_object) { double('HolyRider::Service::Watcher::UpdateTrophyTopService.new') }
  let(:player_id) { 'player_id' }
  let(:trophy_id) { 'trophy_id' }

  it { is_expected.to be_processed_in :trophies }
  it { is_expected.to be_retryable 2 }
  it { is_expected.to save_backtrace 20 }

  describe '#perform' do
    before do
      allow(service).to receive(:new).and_return(service_object)
      allow(service_object).to receive(:call)
    end

    it 'should create service object' do
      expect(service).to receive(:new).with(player_id: player_id, trophy_id: trophy_id)

      subject.perform(player_id, trophy_id)
    end

    it 'should call UpdateTrophyTopService service' do
      expect(service_object).to receive(:call)

      subject.perform(player_id, trophy_id)
    end
  end
end
