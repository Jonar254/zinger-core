class ApiController < ApplicationController
  before_action :reset_thread, :authenticate_request, :check_limit, :check_version

  private

  def authenticate_request
    customer = CustomerSession.fetch_customer(request.headers['Authorization'])

    error_msg = if customer.nil?
      I18n.t('validation.invalid', param: 'authorization')
    elsif customer.is_blocked?
      I18n.t('auth.account_blocked', platform: PlatformConfig['name'])
    end

    if error_msg.present?
      render status: 401, json: { success: false, message: error_msg, reason: 'UNAUTHORIZED' }
      return
    end

    customer.make_current
  end

  def check_limit
    resp = Core::Ratelimit.reached?(request)
    if resp
      render status: 429, json: { success: false, message: resp }
      return
    end
  end

  def reset_thread
    Customer.reset_current
  end

  def check_version
    raise VersionCake::ObsoleteVersionError.new '' if request_version.to_i != 2
  end
end
