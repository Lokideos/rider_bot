# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HolyRider::Service::Bot::ProcessCommandService do
  let(:input_commands) { [valid_command, valid_edited_command, invalid_command] }
  let(:valid_command) { { 'message' => 'info' } }
  let(:valid_edited_command) { { 'edited_message' => 'info' } }
  let(:invalid_command) { { 'invalid_message' => 'info' } }
  let(:worker) { HolyRider::Workers::ProcessCommand }

  subject { HolyRider::Service::Bot::ProcessCommandService.new(input_commands) }

  context 'with valid attributes' do
    it 'should enqueue HolyRider::Workers::ProcessCommand worker with correct parameters' do
      input_commands[0..1].each do |command|
        expect(worker).to receive(:perform_async).with(command, command.keys.first)
      end

      subject.call
    end
  end

  context 'with invalid attributes' do
    it 'should not enqueue HolyRider::Workers::ProcessCommand worker with incorrect message_type' do
      expect(worker).to_not receive(:perform_async).with(invalid_command,
                                                         invalid_command.keys.first)

      subject.call
    end
  end
end
