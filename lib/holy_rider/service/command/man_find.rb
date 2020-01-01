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
          message = ['<b>Поиск информации об одной игре</b>']
          message << 'Сначала идет поиск игры, наименование которой начинается с введеной ' \
                     'игроком информации'
          message << 'Например, запрос <code>/find the witch</code> ' \
                      'найдет игру <code>The Witcher 3: Wild Hunt</code>'
          message << 'Если такая игра не найдена, то идет поиск по играм, в названии которых ' \
                     'содержатся слова или части слов, введенные игроком в любом порядке'
          message << 'Например, запрос <code>/find mass andro</code> и запрос ' \
                      '<code>/find andro mass</code> найдут одну и ту же игру: ' \
                      '<code>Mass Effect: Andromeda</code>'
          message << 'Если какой-либо из поисковых запросов выдает несколько игр, то выводится ' \
                      'та игра из списка найденных игр, по которой был получен последний трофей'
          message << 'При этом регистр не учитывается, то есть поисковый запрос ' \
                      '<code>/find the wit</code> и <code>/find The wit</code> найдет ' \
                      'одни и те же игры'
          message << 'Если игр не найдено, то выводится сообщение <code>Игра не найдена</code>'

          [message.join("\n")]
        end
      end
    end
  end
end
