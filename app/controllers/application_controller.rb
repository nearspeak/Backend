##
# The main application controller.
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?

  before_action :set_locale

  protected

  ##
  # Add firstname and lastname to the device authentication.
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :first_name
    devise_parameter_sanitizer.for(:sign_up) << :last_name
    devise_parameter_sanitizer.for(:sign_up) << :cms_lang
  end

  ##
  # Set the current locale for the customer, or fall back to the default one.
  def set_locale
    # Use default local in the test environment
    if Rails.env.test?
      return I18n.default_locale
    end
    
    if current_customer.nil?
      return I18n.default_locale
    end

    if CustomersHelper.is_valid_language(current_customer.cms_lang)
      return I18n.locale = current_customer.cms_lang || I18n.default_locale
    end

    I18n.default_locale
  end
end
