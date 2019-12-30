# frozen_string_literal: true

module HolyRider
  module Service
    module Command
      class ManFind
        def initialize(command, message_type)
          @command = command
          @message_type = message_type
        end

        def call
          message = ['Поиск информации об одной игре']
          message << 'Сначала идет поиск игры, наименование которой начинается с введеной ' \
                     'пользователем информации'
          message << 'Если такая игра не найдена, то идет поиск по играм, в названии которых ' \
                     'содержатся слова или части слов, введенные пользователем в любом порядке'
          message << 'Если какой-либо из поисковых запросов выдает несколько игр, то выводится ' \
                      'та игра из списка найденных игр, по которой был получен последний трофей'
          message << 'При этом регистр не учитывается, то есть поисковый запрос ' \
                      "'the wit' и 'The wit' - это одно и то же"
          message << "Если игр не найдено, то выводится сообщение 'Игра не найдена'"

          [message.join("\n")]
        end
      end
    end
  end
end
