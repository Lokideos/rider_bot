# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HolyRider::Workers::ProcessCommand do
  let(:service) { HolyRider::Service::CommandService }
  let(:service_object) { double('HolyRider::Service::CommandService.new') }
  let(:command) { 'command' }
  let(:message_type) { 'message_type' }

  it { is_expected.to be_processed_in :commands }
  it { is_expected.to be_retryable 2 }
  it { is_expected.to save_backtrace 20 }

  describe '#perform' do
    before do
      allow(service).to receive(:new).and_return(service_object)
      allow(service_object).to receive(:call)
    end

    it 'should create service object with correct attributes' do
      expect(service).to receive(:new).with(command, message_type)

      subject.perform(command, message_type)
    end

    it 'should call CommandService service' do
      expect(service_object).to receive(:call)

      subject.perform(command, message_type)
    end
  end
end
