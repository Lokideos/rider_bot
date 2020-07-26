# frozen_string_literal: true

class MessageThread < Sequel::Model
  MessageThread.plugin :timestamps, update_on_create: true

  dataset_module do
    def selected_message_threads(thread_ids)
      where(message_thread_id: thread_ids).all
    end
  end
end
