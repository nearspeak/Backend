##
# The omni authentication callbacks controller.
class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_filter :authenticate_customer!
  
  ##
  # Authenticate different providers.
  def all
    p env['omniauth.auth']
    customer = Customer.from_omniauth(env['omniauth.auth'], current_customer)
    if customer.persisted?
      flash[:notice] = 'Signed in successfully.'
      sign_in_and_redirect(customer)
    else
      session['devise.user_attributes'] = customer.attributes
      redirect_to new_customer_registration_url
    end
  end

  ##
  # Handle authentication fails.
  def failure
    #handle you logic here..
    #and delegate to super.
    super
  end

  alias_method :facebook, :all
  alias_method :twitter, :all
  alias_method :google_oauth2, :all
end
