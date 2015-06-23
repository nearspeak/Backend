require 'test_helper'

class API::V1::LoginControllerTest < ActionController::TestCase
  setup do
    @customer = customers(:customer_one)
  end
  
  test "get auth token" do
    post(:get_auth_token, { email: @customer.email, password: 'secret@pwd' })
    
    assert_response :success
    
    json = JSON.parse(response.body)
    
    #puts "DBG: auth_token: " + json['auth_token']
    
    # check if the authentication token is valid
    assert_not_nil json['auth_token'], 'Authentication token is not set'
    assert_not_empty json['auth_token'], 'Authentication token is empty'
  end
end
