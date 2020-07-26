# frozen_string_literal: true

require 'pry-byebug'

module HolyRider
  module Service
    module Screenshots
      class ProcessScreenshotsService
        def initialize(token:)
          @token = token
          @get_threads_client = HolyRider::Client::PSN::Messages::GetThreads
          @create_threads_service = HolyRider::Service::Screenshots::CreateMessageThreadsService
          @prepare_download_service = HolyRider::Service::Screenshots::PrepareDownloadService
        end

        def call
          last_threads = @get_threads_client.new(@token).request_threads_list
          return if last_threads.nil? || last_threads.empty?

          thread_ids = last_threads.map { |thread| thread['threadId'] }
          existing_threads = MessageThread.selected_message_threads(thread_ids)
          existing_thread_ids = existing_threads.map(&:message_thread_id)
          new_thread_ids = thread_ids - existing_thread_ids
          new_threads = last_threads.select { |thread| new_thread_ids.include? thread['threadId'] }
          return if (new_threads + existing_threads).empty?

          prepared_new_threads = filtered_threads(new_threads)
          return if (prepared_new_threads + existing_threads).empty?

          threads_to_update = modified_threads(last_threads, existing_threads, existing_thread_ids)
          update_threads_date(threads_to_update, existing_threads)

          @create_threads_service.new(message_threads: prepared_new_threads).call
          @prepare_download_service.new(threads: (prepared_new_threads + threads_to_update),
                                        token: @token).call
        end

        private

        def update_threads_date(threads, existing_threads)
          threads.each do |thread|
            existing_threads.find do |message_thread|
              message_thread.message_thread_id == thread['threadId']
            end.update(last_modified_date: thread['threadModifiedDate'])
          end
        end

        def filtered_threads(threads)
          threads.select do |thread|
            thread['threadMembers'].any? do |messenger_info|
              Player.active.find(trophy_account: messenger_info['onlineId'])
            end
          end
        end

        def modified_threads(last_threads, existing_threads, existing_thread_ids)
          threads_to_check = last_threads.select do |thread|
            existing_thread_ids.include? thread['threadId']
          end

          threads_to_check.reject do |thread_to_check|
            existing_threads.find do |existing_thread|
              existing_thread.message_thread_id == thread_to_check['threadId']
            end.last_modified_date == thread_to_check['threadModifiedDate']
          end
        end
      end
    end
  end
end
