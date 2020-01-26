# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HolyRider::Service::Bot::DeleteMessageService do
  let(:client_object) { double('non_default_client.new') }
  let(:telegram_client) { HolyRider::Client::Telegram }
  let(:telegram_client_object) { double('HolyRider::Client::Telegram.new') }
  let(:message_to_delete_uid) { 'message_to_delete_uid' }
  let(:chat_id) { 'chat_id' }
  let(:message_id) { 'message_id' }
  let(:message_to_delete_info) { { chat_id: chat_id, message_id: message_id } }
  let(:application_redis) { HolyRider::Application.instance.redis }

  before do
    allow(telegram_client).to receive(:new).and_return(telegram_client_object)
    allow(telegram_client_object).to receive(:delete_message)
    allow(client_object).to receive(:delete_message)
  end

  subject do
    HolyRider::Service::Bot::DeleteMessageService.new(message_uid: message_to_delete_uid)
  end

  context 'info about message to delete exists in redis' do
    before do
      application_redis.hmset("holy_rider:bot:messages:to_delete:info:#{message_to_delete_uid}",
                              message_to_delete_info.flatten)
      application_redis.sadd('holy_rider:bot:messages:to_delete', message_to_delete_uid)
    end

    context 'with default client' do
      subject do
        HolyRider::Service::Bot::DeleteMessageService.new(message_uid: message_to_delete_uid)
      end

      it 'should call :delete_message method on client with correct attributes' do
        expect(telegram_client_object).to receive(:delete_message).with(chat_id: chat_id,
                                                                        message_id: message_id)

        subject.call
      end
    end

    context 'with custom client' do
      subject do
        HolyRider::Service::Bot::DeleteMessageService.new(message_uid: message_to_delete_uid,
                                                          client: client_object)
      end

      it 'should call :delete_message method on client with correct attributes' do
        expect(client_object).to receive(:delete_message).with(chat_id: chat_id,
                                                               message_id: message_id)

        subject.call
      end
    end

    it 'should remove message_uid from correct redis set' do
      subject.call

      expect(
        application_redis.smembers('holy_rider:bot:messages:to_delete')
      ).to_not include(message_to_delete_uid)
    end

    it 'should delete message info from redis key containing message_uid for deletion' do
      subject.call

      expect(
        application_redis.hgetall("holy_rider:bot:messages:to_delete:info:#{message_to_delete_uid}")
      ).to be_empty
    end
  end

  context 'info about message to delete does not exist in redis' do
    it 'should return nil' do
      expect(subject.call).to be_nil
    end
  end
end
