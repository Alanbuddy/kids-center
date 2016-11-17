# encoding: utf-8
module ErrCode

  USER_NOT_EXIST = -1
  WRONG_PASSWORD = -2
  USER_EXIST = -3
  WRONG_VERIFY_CODE = -4
  USER_NOT_VERIFIED = -5
  REQUIRE_SIGNIN = -6
  NO_CENTER = -7
  BOOK_EXIST = -8
  BOOK_NOT_EXIST = -9
  ANNOUNCEMENT_NOT_EXIST = -10
  CENTER_NOT_EXIST = -11
  COURSE_NOT_EXIST = -12
  COURSE_INST_EXIST = -13
  COURSE_INST_NOT_EXIST = -14
  WRONG_CAPTCHA = -15
  BOOK_NOT_RETURNED = -16
  BOOK_IN_TRANSFER = -17
  BOOK_NOT_IN_TRANSFER = -18
  BOOK_NOT_AVAILABLE = -19

  def self.ret_false(code)
    msg = self.message(code)
    return nil if msg.nil?
    retval = { success: false }
    retval.merge({code: code, message: self.message(code)})
  end

  def self.message(code)
    case code
    when USER_NOT_EXIST
      "帐号不存在"
    when WRONG_PASSWORD
      "密码错误"
    when USER_EXIST
      "帐号已存在"
    when WRONG_VERIFY_CODE
      "手机验证码错误"
    when USER_NOT_VERIFIED
      "手机号未验证"
    when REQUIRE_SIGNIN
      "未登录"
    when NO_CENTER
      "未分配儿童中心"
    when BOOK_EXIST
      "已存在相同书号的图书"
    when BOOK_NOT_EXIST
      "图书不存在"
    when ANNOUNCEMENT_NOT_EXIST
      "公告不存在"
    when CENTER_NOT_EXIST
      "儿童中心不存在"
    when COURSE_NOT_EXIST
      "课程不存在"
    when COURSE_INST_EXIST
      "已报名"
    when COURSE_INST_NOT_EXIST
      "未报名"
    when WRONG_CAPTCHA
      "图形验证码错误"
    when BOOK_NOT_RETURNED
      "该绘本未归还"
    when BOOK_IN_TRANSFER
      "绘本迁移中"
    when BOOK_NOT_IN_TRANSFER
      "绘本不在此次迁移中"
    when BOOK_NOT_AVAILABLE
      "绘本不在架上"
    else
      nil
    end
  end
end
