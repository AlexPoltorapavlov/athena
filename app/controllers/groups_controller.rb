class GroupsController < ApplicationController
  before_action :set_group, only: %i[edit update destroy]

  def index
    @groups = Group.all
  end

  def new
    @group = Group.new
    @chats = Chat.all
  end

  def edit
    @chats = Chat.all
  end

  def update
    if @group.update(group_params)
      redirect_to groups_path, notice: 'Group was successfully updated.'
    else
      render :edit
    end
  end

  def create
    @group = Group.new(group_params)

    if @group.save
      redirect_to groups_path, notice: 'Группа успешно создана'
    else
      render :new, alert: @group.errors.full_messages.to_sentence
    end
  end

  def destroy
    @group.destroy
    if @group.destroyed?
      redirect_to groups_path, notice: 'Группа успешно удалена'
    else
      render :edit, alert: @group.errors.full_messages.to_sentence
    end
  end

  private

  def set_group
    @group = Group.find(params[:id])
  end

  def group_params
    params.require(:group).permit(:group_name, chat_ids: [])
  end
end
