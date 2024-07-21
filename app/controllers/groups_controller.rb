class GroupsController < ApplicationController
  before_action :set_group, only: %i[edit update]

  def index
    @groups = Group.all
  end

  def new
    @group = Group.new
    @chats = Chat.all
  end

  def edit
  end
  def update
    if @group.update(group_params)
      redirect_to index, notice: 'Group was successfully updated.'
    else
      render :edit
    end
  end

  def create
    @group = Group.new(group_params)

    if @group.save
      redirect_to @group, notice: 'Group was successfully created.'
    else
      render :new
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
