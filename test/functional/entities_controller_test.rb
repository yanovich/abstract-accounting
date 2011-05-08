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

  test "should create entity" do
    assert_difference('Entity.count') do
       xml_http_request :post, :create, :entity => { :tag => 'A Corp. tester' }
    end
    assert_equal 1, Entity.where(:tag =>'A Corp. tester').count,
      'Entity \'A Corp. tester\' not saved'
  end

  test "should update entity" do
    xml_http_request :put, :update, :id => @entity.to_param,
      :entity => { :tag => 'A Corp. tester update' }
    assert_response :success
    assert_equal 'A Corp. tester update', Entity.find(@entity.id).tag,
      'Entity \'A Corp. tester\' not edited'
  end
end
