class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
    render :text => 'Access Denied!'
  end

  # This will *ONLY* ensure that current user is a leader of 1 or more chapter
  def authorize_leader!
    raise CanCan::AccessDenied if current_user.managed_chapters.count.zero?
  end

  def token_authenticate_user!
    api_token = ::UserApiToken.where(:token => request.headers['X-Access-Token']).first()
    if api_token
      user = api_token.user

      request.env["devise.skip_trackable"] = true
      session[:user_is_api_user] = true

      sign_in user, :store => false
    end
  end

  def is_api_user?
    !! session[:user_is_api_user]
  end

  # https://github.com/plataformatec/devise/wiki/How-To:-Use-Recaptcha-with-Devise
  def devise_verify_captcha
    self.resource = resource_class.new
    unless verify_recaptcha(model: self.resource)
      respond_with_navigational(resource) { render :new }
    end
  end

end