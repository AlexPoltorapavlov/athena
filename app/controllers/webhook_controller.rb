class WebhookController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext

  self.session_store = :memory_store

  # use callbacks like in any other controller
  around_action :with_locale
  # before_action :is_chat?

  # Every update has one of: message, inline_query, chosen_inline_result,
  # callback_query, etc.
  # Define method with the same name to handle this type of update.
  def message(message)
    return if chat['type'] != 'private'
    # respond_with(:message, text: message['text'])
  end

  def start_mailing!(*)
    return if chat['type'] != 'private'
    save_context :get_mail
    respond_with(:message, text: "Напишите сообщение для рассылки")
  end

  def get_mail(message=nil, *)
    return if chat['type'] != 'private'

    if message
      @message = update['message']['text']
      puts "Message received: #{@message}"
      chats = Chat.all
      list_of_chats = chats.map(&:chat_name).join(", ")
      puts ("Значение list_of_chats: \n #{list_of_chats}")
      save_context :choose_chats
      respond_with :message, text: "Выберите чаты.\nСписок всех чатов: \n#{list_of_chats}"

    else
      save_context :get_mail
      puts "No message received"
      respond_with :message, text: 'Попробуйте написать сообщение еще раз'
    end

  end

  def choose_chats(message='', *)
    return if chat['type'] != 'private'
    puts ("Заход в choose_chats \n Значение передаваемой message: \n #{message}")
    selected_chats = update['message']['text']
    puts ("Значение переменной selected_chats: \n #{selected_chats}")

    # selected_chats = selected_chats.split(/,\s*/).map { |chat| chat.split('-').first.strip }
    puts("Список выбранных чатов: #{selected_chats}")
  end

  def my_chat_member(word = nil, *other_words)

    bot_status = update['my_chat_member']['new_chat_member']['status']
    chat_info = update['my_chat_member']['chat']

    if bot_status == 'member'
      chat = Chat.new( chat_id: chat_info['id'], chat_name: chat_info['title']+chat_info['id'].to_s, group: nil )
      chat.save!
    elsif bot_status == 'left'
      chat = Chat.find_by(chat_id: chat_info['id'])
      chat.destroy!
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
    return if chat['type'] != 'private'

    user = find_user_by_name(from['username'])

    if user.nil?
      response = "Привет, #{from['first_name']}! Тебя нет в системе, обратись к администратору."
    elsif user && user.confirmed_at.nil?
      password = SecureRandom.hex(4)

      user.password = password
      user.confirmed_at = Time.now()

      if user.save
        response = "Приветствую! Данные для входа: \n
        Логин: ваш адресс электронной почты \n
        Пароль: \"#{password}\" \n
        Приятного пользования!"
      else
        response = "Приветствую! Я не смогла создать вам аккаунт, попробуй запустить меня еще раз или обратитесь
                    к администратору"
      end

    else
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

  def string_chats_to_array(ctring_chats)

  end

end
