require 'test_helper'

class EntitiesControllerTest < ActionController::TestCase
  setup do
    @entity = entities(:acorp)
  end

  test "should get index entity" do
    get :index
    assert_response :success
    assert_not_nil assigns(:entities)
  end

  test "should get new entity" do
    xml_http_request :get, :new
    assert_response :success
  end

  test "should get edit entity" do
    xml_http_request :get, :edit, :id => @entity.to_param
    assert_response :success
  end

end
