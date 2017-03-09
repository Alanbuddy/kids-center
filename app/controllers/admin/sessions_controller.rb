class Admin::SessionsController < Admin::ApplicationController
  before_filter :require_sign_in, only: []

  # show the index page
  def index
    if @current_user.try(:user_type) == User::ADMIN
      redirect_to admin_staffs_path and return
    end
  end

  # signin
  def create
    retval = User.signin_admin(params[:mobile], params[:password])
    if retval.class == Hash && retval[:auth_key].present?
      cookies[:auth_key] = {
        :value => retval[:auth_key],
        :expires => Rails.env == "production" ? 5.minutes.from_now : 24.months.from_now,
        :domain => :all
      }
    end
    render json: retval_wrapper(retval)
  end

  def forget_password
    if params[:captcha] != session[:_rucaptcha]
      render json: retval_wrapper(ErrCode::WRONG_CAPTCHA) and return
    end
    user = User.admin.where(mobile: params[:mobile]).first
    retval = user.nil? ? ErrCode::USER_NOT_EXIST : user.forget_password
    render json: retval_wrapper(retval)
  end

  def reset_password
    user = User.admin.where(id: params[:id]).first
    retval = user.nil? ? ErrCode::USER_NOT_EXIST : user.reset_password(params[:password], params[:verify_code])
    render json: retval_wrapper(retval)
  end

  def change_password
    retval = @current_user.change_password(params[:password], params[:new_password])
    render json: retval_wrapper(retval) and return
  end

  def signout
    cookies.delete(:auth_key, :domain => :all)
    redirect_to admin_sessions_path
  end
end
