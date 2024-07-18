class WebhookController < Telegram::Bot::UpdatesController
  # use callbacks like in any other controller
  around_action :with_locale
  before_action :is_chat?

  # Every update has one of: message, inline_query, chosen_inline_result,
  # callback_query, etc.
  # Define method with the same name to handle this type of update.
  def message(message)
    # respond_with(:message, text: message['text'])
  end

  def start_mailing!
    reply_with(:message, text: "Напишите сообщение, которое хотите отправить")
  end


  def my_chat_member(word = nil, *other_words)

    bot_status = update['my_chat_member']['new_chat_member']['status']
    chat_info = update['my_chat_member']['chat']

    puts "Вывод chat_info: \n #{chat_info}"

    if bot_status == 'member'
      puts 'Вход в условие с bot_status == \'member\''
      chat = Chat.new( chat_id: chat_info['id'], chat_name: chat_info['title']+chat_info['id'].to_s, group: nil )
      puts 'Было создание сущности чата.'
      if chat.save!
        puts 'Чат сохранен'
      end
    elsif bot_status == 'left'
      chat = Chat.find_by(chat_id: chat_info['id'])
      if chat
        puts "Попытка удалить чат с ID #{chat_info['id']}..."
        if chat.destroy
          puts "Чат с ID #{chat_info['id']} успешно удален."
        else
          puts "Не удалось удалить чат с ID #{chat_info['id']}. Ошибки: #{chat.errors.full_messages.join(', ')}"
        end
      else
        puts "Чат с ID #{chat_info['id']} не найден."
      end
    end

  end

  # For the following types of updates commonly used params are passed as arguments,
  # full payload object is available with `payload` instance method.
  #
  #   message(payload)
  #   inline_query(query, offset)
  #   chosen_inline_result(result_id, query)
  #   callback_query(data)

  # Define public methods ending with `!` to handle commands.
  # Command arguments will be parsed and passed to the method.
  # Be sure to use splat args and default values to not get errors when
  # someone passed more or less arguments in the message.
  def start!(word = nil, *other_words)
    puts "\n\nStart! method called\n\n"
    user = find_user_by_name(from['username'])
    puts "\n\nUser found: #{user.id}\n\n" if user

    if user.nil?
      login = SecureRandom.hex(4)
      password = SecureRandom.hex(4)

      puts "\n\nCreating new user with login: #{login} and password: #{password}\n\n"

      @user = User.new(email: login, password: password, telegram_link: from['username'],
                       username: login, login: login )

      if @user.save
        puts "\n\nUser saved successfully\n\n"
        response = "Приветствую! Данные для входа: \n
        Логин: \"#{login}\" \n
        Пароль: \"#{password}\" \n
        Приятного пользования!"
      else
        puts "\n\nFailed to save user: #{@user.errors.full_messages.join(', ')}\n\n"

        response = "Приветствую! Я не смогла создать тебе аккаунт, попробуй запустить меня еще раз."
      end
    else
      puts "\n\nWelcome back, #{from['first_name']}!\n\n"

      response = "С возвращением, #{from['first_name']}!"
    end

    respond_with :message, text: response
  end

    # do_smth_with(word)

    # full message object is also available via `payload` instance method:
    # process_raw_message(payload['text'])

    # There are `chat` & `from` shortcut methods.
    # For callback queries `chat` is taken from `message` when it's available.
    # response = from ? "Привет, #{from['username']}!" : 'Привет!'

    # # There is `respond_with` helper to set `chat_id` from received message:
    # respond_with :message, text: response

    # # `reply_with` also sets `reply_to_message_id`:
    # reply_with :photo, photo: File.open('party.jpg')



  private

  def with_locale(&block)
    I18n.with_locale(locale_for_update, &block)
  end

  def locale_for_update
    if from
      # locale for user
    elsif chat
      # locale for chat
    end
  end

  def find_user_by_name(name)
    User.find_by(telegram_link: name)
  end

  def is_chat?
    puts ('сработал is_chat')
  end

end
