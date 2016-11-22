class UserMobile::CoursesController < UserMobile::ApplicationController
  skip_before_filter :require_sign_in, only: [:notify]
  # similar to search_new
  def index
    @keyword = params[:keyword]
    if @current_user.client_centers.present?
      @courses = CourseInst.is_available.any_in(center_id: @current_user.client_centers.is_available.map { |e| e.id.to_s})
      if params[:keyword].present?
        @courses = @courses.where(name: /#{params[:keyword]}/)
      end
      @courses = auto_paginate(@courses)[:data]
    end
  end

  def more
    @courses = CourseInst.is_available.any_in(center_id: @current_user.client_centers.is_available.map { |e| e.id.to_s})
    if params[:keyword].present?
      @courses = @courses.where(name: /#{params[:keyword]}/)
    end
    @courses = auto_paginate(@courses)[:data]
    @courses = @courses.map { |e| e.more_info }
    render json: retval_wrapper({more: @courses}) and return
  end

  # course_show
  def show
    @back = params[:back]
    @course = CourseInst.where(id: params[:id]).first
    @course_participate = @current_user.course_participates.where(course_inst_id: @course.id).first
  end

  # wechat_pay
  def new
    @course = CourseInst.where(id: params[:state]).first
    @open_id = Weixin.get_oauth_open_id(params[:code])
    @course_participate = @current_user.course_participates.where(course_inst_id: @course.id).first
    @course_participate = @course_participate || CourseParticipate.create_new(current_user, @course)
    if @course_participate.is_expired
      @course_participate.renew
    end
    if @course_participate.prepay_id.blank?
      @course_participate.unifiedorder_interface(@remote_ip, @open_id)
    end
    @pay_info = @course_participate.get_pay_info
  end

  def notify
    # get out_trade_no, which is the order_id in CourseParticipate
    # ci = CourseParticipate.where(order_id: out_trade_no).first
    # get result_code, err_code and err_code_des
    # ci.update_order(result_code, err_code, err_code_des)
    render :xml => {return_code: "SUCCESS"} and return
  end

  def pay_finished
    @course_participate = CourseParticipate.where(id: params[:id]).first
    @course_participate.update_attributes({pay_finished: true})
    render json: retval_wrapper(nil) and return
  end

  def signin
    info_ary = params[:signin_info]
    course_inst_id, qr_gen_time, class_idx = info_ary.split(';')
    course_participate = @current_user.course_participates.where(course_inst_id: course_inst_id).first
    if course_participate.nil?
      render json: retval_wrapper(ErrCode::COURSE_INST_NOT_EXIST) and return
    else
      retval = course_participate.signin(class_idx.to_i)
      render json: retval_wrapper(retval) and return
    end
  end

  def favorite
    course_inst = CourseInst.where(id: params[:id]).first
    fav = current_user.favorites.where(course_inst: course_inst).first
    fav = fav || current_user.favorites.create(course_inst_id: course_inst.id)
    if params[:favorite].to_s == "true"
      fav.enabled = true
    else
      fav.enabled = false
    end
    fav.save
    render json: retval_wrapper(nil) and return
  end

  def pay_success
    @course = CourseInst.where(id: params[:id]).first
  end
end