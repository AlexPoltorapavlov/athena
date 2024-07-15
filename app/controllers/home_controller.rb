class HomeController < ApplicationController
  def index
    if current_user.is_admin?
      puts('admin signed in')
      redirect_to admin_panel_path
    elsif current_user.is_user?
      puts('user signed in')
      redirect_to account_path
    end
  end

end
