# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HolyRider::Workers::ProcessMessageDeletion do
  let(:service) { HolyRider::Service::Bot::DeleteMessageService }
  let(:service_object) { double('HolyRider::Service::Bot::DeleteMessageService.new') }
  let(:message_uid) { 'message_uid' }

  it { is_expected.to be_processed_in :message_deletion }
  it { is_expected.to be_retryable 5 }
  it { is_expected.to save_backtrace 20 }

  describe '#perform' do
    before do
      allow(service).to receive(:new).and_return(service_object)
      allow(service_object).to receive(:call)
    end

    it 'should create service object with correct attributes' do
      expect(service).to receive(:new).with(message_uid: message_uid)

      subject.perform(message_uid)
    end

    it 'should call DeleteMessageService service' do
      expect(service_object).to receive(:call)

      subject.perform(message_uid)
    end
  end
end
