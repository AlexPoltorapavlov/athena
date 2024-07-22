class WebhookController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  Telegram::Bot::Client.typed_response!


  self.session_store = :memory_store

  # use callbacks like in any other controller
  around_action :with_locale
  before_action :is_chat?

  # Every update has one of: message, inline_query, chosen_inline_result,
  # callback_query, etc.
  # Define method with the same name to handle this type of update.
  def message(message)
    # return if chat['type'] != 'private'
    # respond_with(:message, text: message['text'])
  end

  def callback_query(data)
    case data
    when 'send_to_group'
      choose_groups
    when 'send_to_chat'
      choose_chats
    when 'send_to_everyone'
      confirm_mailing('all')
    when 'rewrite_mail'
      start_mailing!
    when 'confirm_chats'
      confirm_mailing('chat')
    when 'confirm_groups'
      confirm_mailing('group')
    when /\Achat_/
      chat_list_to_select(data)
    when /\Agroup_/
      group_list_to_select(data)
    when 'send_mails_to_groups'
      send_mails_to_groups
    when 'send_mails_to_chats'
      send_mails_to_chats
    when 'choose_all_chats'
      choose_all_chats
    end
  end

  def chat_list_to_select(data)
    chat_id = data.split('_')[1].to_i
    chat = Chat.find(chat_id)
    if @@selected_chats.include?(chat)
      @@selected_chats.delete(chat)
      chat_button_text = chat.chat_name
    else
      @@selected_chats << chat
      chat_button_text = "✅ #{chat.chat_name}"
    end
    edit_message(:text, text: 'Выберите чаты для отправки', reply_markup: {
      inline_keyboard: Chat.all.map { |c| [{ text: (@@selected_chats.include?(c) ? "✅ #{c.chat_name}" : (c == chat ? chat_button_text : c.chat_name)), callback_data: "chat_#{c.id}" }] } << [{text: 'Подтвердить', callback_data: 'confirm_chats'}]
    })
  end

  def confirm_mailing(type_flag)
    groups = []
    chats = []
    if type_flag == 'chat'
      chats = @@selected_chats.map(&:chat_name).join(', ')
      respond_with :message, text: "Текст сообщения: #{@@message_for_mailing}\n\nЧаты: #{chats}", reply_markup: {
        inline_keyboard: [
          [{ text: 'Отправить', callback_data: 'send_mails_to_chats' }],
          [{ text: 'Выбрать чаты заново', callback_data: 'send_to_chat' }],
          [{ text: 'Ввести сообщение заново', callback_data: 'rewrite_mail' }]
        ]
      }
    elsif type_flag == 'group'
      groups = @@selected_groups.map(&:group_name).join(', ')
      respond_with :message, text: "Текст сообщения: #{@@message_for_mailing}\n\Группы: #{groups}", reply_markup: {
        inline_keyboard: [
          [{ text: 'Отправить', callback_data: 'send_mails_to_groups' }],
          [{ text: 'Выбрать группы заново', callback_data: 'send_to_group' }],
          [{ text: 'Ввести сообщение заново', callback_data: 'rewrite_mail' }]
        ]
      }
    elsif type_flag == 'all'
      chats = Chat.all.map(&:chat_name).join(', ')
      respond_with :message, text: "Текст сообщения: #{@@message_for_mailing}\n\nЧаты: все!", reply_markup: {
        inline_keyboard: [
          [{ text: 'Отправить', callback_data: 'choose_all_chats' }],
          [{ text: 'Выбрать чаты заново', callback_data: 'send_to_chat' }],
          [{ text: 'Ввести сообщение заново', callback_data: 'rewrite_mail' }]
        ]
      }
    end
  end

  def group_list_to_select(data)
    group_id = data.split('_')[1].to_i
    group = Group.find(group_id)
    if @@selected_groups.include?(group)
      @@selected_groups.delete(group)
      group_button_text = group.group_name
    else
      @@selected_groups << group
      group_button_text = "✅ #{group.group_name}"
    end
    edit_message(:text, text: 'Выберите группы для отправки', reply_markup: {
      inline_keyboard: Group.all.map { |c| [{ text: (@@selected_groups.include?(c) ? "✅ #{c.group_name}" : (c == group ? group_button_text : c.group_name)), callback_data: "group_#{c.id}" }] } << [{text: 'Подтвердить', callback_data: 'confirm_groups'}]
    })
  end

  def send_mails_to_chats
    @@selected_chats.each do |chat|
      bot.send_message(chat_id: chat.chat_id, text: @@message_for_mailing)
    end
    respond_with :message, text: 'Сообщение успешно отправлено!'
  end

  def send_mails_to_groups
    chat_ids = Set.new

    @@selected_groups.each do |group|
      group.chats.each do |chat|
        chat_ids.add(chat.chat_id)
      end
    end

    chat_ids.each do |chat_id|
      bot.send_message(chat_id: chat_id, text: @@message_for_mailing)
    end

    respond_with :message, text: 'Сообщение успешно отправлено!'
  end

  def choose_all_chats
    @@selected_chats = Chat.all
    send_mails_to_chats
  end

  def choose_groups
    @@selected_groups = []

    respond_with :message, text: 'Выберите группы для отправки', reply_markup: {
      inline_keyboard: Group.all.map { |c| [{ text: c.group_name, callback_data: "group_#{c.id}" }] } << [{text: 'Подтвердить', callback_data: 'confirm_groups'}]
    }
  end

  def choose_chats
    @@selected_chats = []

    respond_with :message, text: 'Выберите чаты для отправки', reply_markup: {
      inline_keyboard: Chat.all.map { |c| [{ text: c.chat_name, callback_data: "chat_#{c.id}" }] } << [{text: 'Подтвердить', callback_data: 'confirm_chats'}]
    }
  end

  def start_mailing!(*)
    return if chat['type'] != 'private'
    save_context :get_mail
    respond_with(:message, text: "Напишите сообщение для рассылки")
  end

  def get_mail(message=nil, *)
    return if chat['type'] != 'private'

    if message
      @@message_for_mailing = update['message']['text']

      respond_with :message, text: "Кому хотите отправить сообщение? \n", reply_markup: {
        inline_keyboard: [
          [{ text: 'Отправить в группу',        callback_data: 'send_to_group' }],
          [{ text: 'Отправить в чат',           callback_data: 'send_to_chat' }],
          [{ text: 'Отправить всем',            callback_data: 'send_to_everyone' }],
          [{ text: 'Ввести сообщение заново',   callback_data: 'rewrite_mail' }]
        ]
      }

    else
      save_context :get_mail
      puts "No message received"
      respond_with :message, text: 'Попробуйте написать сообщение еще раз'
    end
  end

  def my_chat_member(word = nil, *other_words)

    bot_status = update['my_chat_member']['new_chat_member']['status']
    chat_info = update['my_chat_member']['chat']

    if bot_status == 'member'
      chat = Chat.new( chat_id: chat_info['id'], chat_name: chat_info['title']+chat_info['id'].to_s )
      chat.save!
    elsif bot_status == 'left'
      chat = Chat.find_by(chat_id: chat_info['id'])
      chat.destroy!
    end

  end

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

  def find_chat_by_name(name)
    Chat.find_by(chat_name: name)
  end

  def add_chat_to_db(chat_id, chat_name)
    chat = Chat.new( chat_id: chat_id, chat_name: chat_name + chat_id.to_s )
    chat.save!
  end

  def is_chat?
    if chat['type'] != 'private'
      unless Chat.find_by(chat_id: chat['id'])
        add_chat_to_db(chat['id'], chat['title'])
      else
        return
      end
    end
  end
end
