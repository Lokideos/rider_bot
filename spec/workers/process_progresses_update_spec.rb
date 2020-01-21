# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HolyRider::Workers::ProcessProgressesUpdate do
  let(:service) { HolyRider::Service::Watcher::UpdateGameProgressesService }
  let(:service_object) { double('HolyRider::Service::Watcher::UpdateGameProgressesService.new') }
  let(:game_id) { 'game_id' }

  it { is_expected.to be_processed_in :trophies }
  it { is_expected.to be_retryable 5 }
  it { is_expected.to save_backtrace 20 }

  describe '#perform' do
    before do
      allow(service).to receive(:new).and_return(service_object)
      allow(service_object).to receive(:call)
    end

    it 'should create service object' do
      expect(service).to receive(:new).with(game_id: game_id)

      subject.perform(game_id)
    end

    it 'should call UpdateGameProgressesService service' do
      expect(service_object).to receive(:call)

      subject.perform(game_id)
    end
  end
end
