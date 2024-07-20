class ChatsController < ApplicationController

  before_action :set_chat, only: %i[show edit update]

  def index
    @chats = Chat.all
  end

  def show; end

  def edit; end

  def update
    if @chat.update(chat_params)
      redirect_to chats_path, notice: 'Чат успешно обновлен'
    else
      render :edit, alert: @chat.errors.full_messages.to_sentence
    end
  end

  private

  def set_chat
    @chat = Chat.find(params[:id])
  end

  def chat_params
    params.require(:chat).permit(:chat_name)
  end

end
