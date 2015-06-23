##
# The API login controller.
class API::V1::LoginController < ApplicationController
  protect_from_forgery with: :null_session

  ##
  # Get the authenticaton token for the customer.
  def get_auth_token
    email = params[:email]
    password = params[:password]

    if email.nil?
      render :status => 400, :json => { :error => { :message => 'The request must contain a valid email.', :code => 'InvalidRequest' }}
      return
    end

    if password.nil?
      render :status => 400, :json => { :error => { :message => 'The request must contain a valid password.', :code => 'InvalidRequest' }}
      return
    end

    customer = Customer.find_by_email(email.downcase)

    if customer.nil?
      render :status => 400, :json => { :error => { :message => 'User not found.', :code => 'InvalidRequest' }}
      return
    end

    if customer.valid_password?(password)
      customer.ensure_authentication_token
      render :status => 200, :json => { :auth_token => customer.get_devise_auth_token }
    else
      render :status => 400, :json => { :error => { :message => 'Invalid email or password.', :code => 'InvalidRequest' }}
    end
  end

  ##
  # Sign the customer out from the system and invalidate the authentication token.
  def sign_out
    email = params[:email]
    auth_token = params[:auth_token]

    if email.nil?
      render :status => 400, :json => { :error => { :message => 'The request must contain a valid email.', :code => 'InvalidRequest' }}
      return
    end

    customer = Customer.find_by_email(email.downcase)

    if auth_token.nil?
      render :status => 400, :json => { :error => { :message => 'The request must contain a valid authentication token.', :code => 'InvalidRequest' }}
      return
    end

    if customer.remove_devise_auth_token(auth_token)
      render :status => 200, :json => { :message => 'Logout was successful.', :code => 'OK' }
    else
      render :status => 400, :json => { :error => { :message => 'Logout went wrong.', :code => 'LogoutError' }}
    end
  end

  ##
  # Sign the customer in via facebook
  def sign_in_with_facebook
    auth_token = params[:auth_token]

    if auth_token.nil?
      render :status => 400, :json => { :error => { :message => 'The request must contain a valid authentication token.', :code => 'InvalidRequest' }}
      return
    end

    graph = Koala::Facebook::API.new(auth_token)
    facebook_data = graph.get_object('me')

    if facebook_data.nil?
      render :status => 400, :json => { :error => { :message => 'Facebook data is empty.', :code => 'FacebookError' }}
      return
    end

    customer = Customer.from_facebook(auth_token, facebook_data)

    if customer.nil?
      render :status => 400, :json => { :error => { :message => 'Facebook sign in error.', :code => 'SignInError' }}
      return
    end

    if customer.persisted?

      # create default device token
      customer.ensure_authentication_token
      render :status => 200, :json => { :auth_token => customer.get_devise_auth_token }
    else
      render :status => 400, :json => { :error => { :message => 'Facebook sign in error.', :code => 'SignInError' }}
    end
  end
end
