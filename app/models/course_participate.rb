require 'httparty'
class CourseParticipate

  include HTTParty
  base_uri "https://api.mch.weixin.qq.com"
  format  :xml

  APPID = "wxfe4fd89f6f5f9f57"
  SECRET = "01265a8ba50284999508d680f7387664"
  APIKEY = "1juOmajJrHO3f2NFA0a8dIYy2qAamtnK"
  MCH_ID = "1388434302"
  NOTIFY_URL = "http://babyplan.bjfpa.org.cn/welcome/test_pay"

  include Mongoid::Document
  include Mongoid::Timestamps

  field :pay_at, type: Integer
  field :sign_in_time, type: String
  field :paid, type: Boolean, default: false
  field :order_id, type: String

  belongs_to :course_inst
  belongs_to :client, class_name: "User", inverse_of: :course_participates


  def self.create_new(client, course_inst, remote_ip, openid)
    cp = self.create({order_id: Util.random_str(32)})
    cp.course_inst = course_inst
    cp.client = client
    cp.save
    return cp.unifiedorder_interface(remote_ip, openid)
  end

  def unifiedorder_interface(remote_ip, openid)
    nonce_str = Util.random_str(32)
    data = {
      "appid" => APPID,
      "mch_id" => MCH_ID,
      "nonce_str" => nonce_str,
      "body" => self.course_inst.course.name,
      "out_trade_no" => self.order_id,
      "total_fee" => (self.course_inst.price_pay * 100).to_s,
      "spbill_create_ip" => remote_ip,
      "notify_url" => NOTIFY_URL,
      "trade_type" => "JSAPI",
      "openid" => openid
    }
    signature = Util.sign(data, APIKEY)
    data["sign"] = signature

    response = CourseParticipate.post("/pay/unifiedorder",
      :body => Util.hash_to_xml(data))
    logger.info "AAAAAAAAAAAAAAAA"
    logger.info response.body
    logger.info "AAAAAAAAAAAAAAAA"

    # todo: handle error messages

    doc = Nokogiri::XML(response.body)
    prepay_id = doc.search('prepay_id').children[0].text
    retval = {
      "appId" => APPID,
      "timeStamp" => Time.now.to_i.to_s,
      "nonceStr" => Util.random_str(32),
      "package" => "prepay_id=" + prepay_id,
      "signType" => "MD5"
    }
    signature = Util.sign(retval, APIKEY)
    retval["sign"] = signature
    return retval
  end
end