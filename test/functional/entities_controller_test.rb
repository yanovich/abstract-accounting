require 'test_helper'

class EntitiesControllerTest < ActionController::TestCase
  test "should get index entity" do
    get :index
    assert_response :success
    assert_not_nil assigns(:entities)
  end

  test "should get new entity" do
    xml_http_request :get, :new
    assert_response :success
  end

end
