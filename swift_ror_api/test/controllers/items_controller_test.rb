require "test_helper"

class ItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @todo = todos(:one)
    @item = items(:one)
    @bad_todo = -1
    @bad_item = -1
  end

  test "should get index" do
    get todo_items_url(@todo), as: :json
    assert_response :success
  end

  test "should create item" do
    assert_difference('Item.count') do
      post todo_items_url(@todo), params: { item: { done: @item.done, name: @item.name, todo_id: @item.todo_id } }, as: :json
    end

    assert_response 201
  end

  test "should show item" do
    get todo_items_url(@todo), as: :json
    assert_response :success
  end

  test "should update item" do
    patch todo_item_url(@todo, @item), params: { item: { done: @item.done, name: @item.name, todo_id: @item.todo_id } }, as: :json
    assert_response 204
  end

  test "should destroy item" do
    assert_difference('Item.count', -1) do
      delete todo_item_url(@todo, @item), as: :json
    end

    assert_response 204
  end

  test "should fail geting index" do
    get todo_items_url(@bad_todo), as: :json
    assert_response 404
  end

  test "should fail creating item" do
    assert_no_difference('Item.count') do
      post todo_items_url(@bad_todo), params: { item: { done: @item.done, name: @item.name, todo_id: @item.todo_id } }, as: :json
    end

    assert_response 404
  end

  test "should fail showing non exitent items" do
    get todo_items_url(@bad_todo), as: :json
    assert_response 404
  end

  test "should fail updating non existent item" do
    patch todo_item_url(@bad_todo, @bad_item), params: { item: { done: @item.done, name: @item.name, todo_id: @item.todo_id } }, as: :json
    assert_response 404
  end

  test "should fail destroying non exitent item" do
    assert_difference('Item.count', 0) do
      delete todo_item_url(@todo, @bad_item), as: :json
    end

    assert_response 404
  end

  test "should fail with unprocesable entity" do
    assert_no_difference('Item.count') do
      post todo_items_url(@todo), params: { item: { done: nil, name: nil, todo_id: nil } }, as: :json
    end

    assert_response 422
  end
end
