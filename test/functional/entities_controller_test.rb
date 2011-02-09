require 'test_helper'

class EntitiesControllerTest < ActionController::TestCase
  test "should get index entity" do
    get :index
    assert_response :success
    assert_not_nil assigns(:entities)
  end
end
