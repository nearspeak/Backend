##
# The main API application controller.
class API::V1::ApiApplicationController < ApplicationController
  protect_from_forgery with: :null_session

  before_filter :auth_customer_from_token!, :except => [:show, :show_by_hardware_id, :add_hardware_id_to_tag, :supported_language_codes, :create, :get_all_uuids]

  ### PRIVATE ###
  private

  ##
  # Authenticate the customer with a given authentication token
  def auth_customer_from_token!
    customer_token = params[:auth_token].presence
    customer = customer_token && Customer.find_by_auth_token(customer_token)

    if customer && Devise.secure_compare(customer.get_devise_auth_token, params[:auth_token])
      # Notice we are passing store false, so the user is not
      # actually stored in the session and a token is needed
      # for every request. If you want the token to work as a
      # sign in token, you can simply remove store: false.
      sign_in customer, store: false
    else
      # user has to provide authentication token!
      render :status => 404, :json => {:error => {:message => 'User not found.', :code => 'UserNotFound'}}
    end
  end
end