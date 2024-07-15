class AdminsController < ApplicationController
  before_action :authorize_admin


  def admin_panel
    @users = User.all
  end

  def new_user
    @user = User.new
  end

  def create_user
    puts "Parameters: #{params.inspect}"
    @user = User.new(user_params)

    if @user.save
      redirect_to admin_panel_path, notice: 'Пользователь успешно создан'
    else
      Rails.logger.debug "User errors: #{@user.errors.full_messages}"
      render :new_user, alert: "Ошибка при создании пользователя: #{@user.errors.full_messages.to_sentence}."
    end
  end

  def edit_user
    @user = User.find(params[:id])
  end

  def update_user
    @user = User.find(params[:id])

    if @user.update(user_params)
      redirect_to admins_path, notice: 'Пользователь успешно обновлен'
    else
      Rails.logger.debug "User errors: #{@user.errors.full_messages}"
      render :edit_user, alert: "Ошибка при обновлении пользователя: #{@user.errors.full_messages.to_sentence}."
    end
  end

  def destroy_user
    @user = User.find(params[:id])
    @user.destroy
    redirect_to admins_path, notice: 'Пользователь успешно удален'
  end

  private

  def user_params
    params.require(:user).permit(:id, :name, :telegram_link, :email, :password, :password_confirmation)
  end


  def authorize_admin
    authorize! :manage, :admin
  end

end
