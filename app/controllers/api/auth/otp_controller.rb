class Api::Auth::OtpController < Api::AuthController
  before_action :send_otp

  def signup
  end

  def login
  end

  def reset_password
  end

  def reset_profile
  end

  private
  
  def send_otp
    params_present = AUTH_PARAMS.select { |key| params[key].present? }
    if params_present.length != 1
      render status: 400, json: { success: false, message: I18n.t('validation.too_many_params', param: AUTH_PARAMS.join(', ')) }
      return
    end

    key = params_present.first
    resp = Customer.send_otp({ param: key, value: params[key], action: params['action'] })
    if resp.class == String
      render status: 400, json: { success: false, message: I18n.t('auth.otp.failed'), reason: { key => [resp] } }
      return
    end

    render status: 200, json: { success: true, message: I18n.t('auth.otp.success'), data: resp }
  end
end
