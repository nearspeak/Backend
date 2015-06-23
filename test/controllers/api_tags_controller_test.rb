require 'test_helper'

class API::V1::TagsControllerTest < ActionController::TestCase

  setup do
    @tag = tags(:tag_one)
    @hardware = hardwares(:hardware_one)
  end
  
  test "show tag in english language" do
    get :show, id: @tag.tag_identifier, lang: "en"
    
    assert_response :success
    
    json = JSON.parse(response.body)
    
    #puts "DBG: json body: " + json.to_s
    
    # check if the response the has the same tag_identifier
    assert_equal json['tags'][0]['tag_identifier'], @tag.tag_identifier, 'Invalid tag identifier'
  end
  
  test "show tag without language" do
    get :show, id: @tag.tag_identifier
    
    assert_response :success
  end
  
  test "show tag by hardware id" do
    get :show_by_hardware_id, id: @hardware.identifier, type: "nfc"
    
    #puts response.body
    
    assert_response :success
  end
  
  test "show supported languages" do
    get :supported_language_codes
    
    assert_response :success
  end
end
