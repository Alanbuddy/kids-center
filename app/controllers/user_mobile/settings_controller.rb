class UserMobile::SettingsController < UserMobile::ApplicationController
  # usercenter
	def index
  end

  # mybook
  def book
  end

  # mycourse
  def course
  end

  # collect
  def collect
  end

  # systemmessage
  def message
  end

  # set
  def account
  end

  def reset_password
  end

  def update_password
    retval = current_user.change_password(params[:old_password], params[:new_password])
    render json: retval_wrapper(retval) and return 
  end

  def sign
  end
end
