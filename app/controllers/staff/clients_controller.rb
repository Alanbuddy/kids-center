class Staff::ClientsController < Staff::ApplicationController

  before_filter :set_active_tab

  def set_active_tab
    @active_tab = "client"
  end

  # show the index page
  def index
    @keyword = params[:keyword]
    users = @keyword.present? ? User.client.any_of({name: /#{Regexp.escape(@keyword)}/},{mobile: /#{Regexp.escape(@keyword)}/}) : User.client.all
    users = users.where(mobile_verified: true)
    @users = auto_paginate(users)
    @users[:data] = @users[:data].map do |e|
      e.client_info
    end
  end

  # def index
  #   @keyword = params[:keyword]
  #   users = @keyword.present? ? current_center.clients.where(name: /#{@keyword}/) : current_center.clients.all
  #   users = users.where(mobile_verified: true)
  #   @users = auto_paginate(users)
  #   @users[:data] = @users[:data].map do |e|
  #     e.client_info
  #   end
  # end

  # create a new user
  # def create
  #   retval = User.create_user(User::CLIENT, params[:mobile], true, current_center)
  #   render json: retval_wrapper(retval)
  # end
  def create
    retval = User.create_user(User::CLIENT, params[:mobile], true)
    render json: retval_wrapper(retval)
  end

  # def verify
  #   user = User.where(id: params[:id]).first
  #   if user.nil?
  #     render json: retval_wrapper(ErrCode::USER_NOT_EXIST) and return
  #   end
  #   retval = user.verify_client(params[:name], params[:password], params[:verify_code])
  #   if retval.nil?
  #     profile = {
  #       "name" => params[:name],
  #       "gender" => params[:gender].to_i,
  #       "parent" => params[:parent],
  #       "address" => params[:address],
  #       "birthday" => params[:birthday]
  #     }
  #     retval = user.update_profile(profile)
  #   end
  #   render json: retval_wrapper(retval)
  # end

  def verify
    user = User.where(id: params[:id]).first
    if user.nil?
      render json: retval_wrapper(ErrCode::USER_NOT_EXIST) and return
    end
    retval = user.verify_client(params[:name], params[:password], params[:verify_code])
    if retval.nil?
      profile = {
        name: params[:name],
        gender: params[:gender].to_i,
        parent: params[:parent],
        address: params[:address],
        birthday: params[:birthday]
      }
      retval = user.update_profile(profile)
    end
    render json: retval_wrapper(retval)
  end

  def show
    @user = User.client.where(id: params[:id]).first
    participates = @user.course_participates
    @participates = auto_paginate(participates)
    @participates[:data] = @participates[:data].map do |e|
      e.participate_info
    end
  end

  # def pay_latefee
  #   @user = User.where(id: params[:id]).first
  #   retval = @user.pay_latefee(current_center)
  #   render json: retval_wrapper(retval) and return
  # end

  # def pay_deposit
  #   @client = User.where(id: params[:id]).first
  #   retval = @client.pay_deposit(current_center)
  #   render json: retval_wrapper(retval) and return
  # end

  # def refund_deposit
  #   @client = User.where(id: params[:id]).first
  #   retval = @client.refund_deposit(current_center)
  #   render json: retval_wrapper(retval) and return
  # end
end
