require "test_helper"

class TodosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @todo = todos(:one)
    @bad_todo = -1
  end

  test "should get index" do
    get todos_url, as: :json
    assert_response :success
  end

  test "should create todo" do
    assert_difference('Todo.count') do
      post todos_url, params: { todo: { created_by: @todo.created_by, title: @todo.title } }, as: :json
    end

    assert_response 200
  end

  test "should show todo" do
    get todo_url(@todo), as: :json
    assert_response :success
  end

  test "should update todo" do
    patch todo_url(@todo), params: { todo: { created_by: @todo.created_by, title: @todo.title } }, as: :json
    assert_response 204
  end

  test "should destroy todo" do
    assert_difference('Todo.count', -1) do
      delete todo_url(@todo), as: :json
    end

    assert_response 204
  end

  test "should fail to get non existent todo" do
    get todo_url(@bad_todo), as: :json
    assert_response 404
  end

  test "should fail updating non existent todo" do
    patch todo_url(@bad_todo), params: { todo: { created_by: @todo.created_by, title: @todo.title } }, as: :json
    assert_response 404
  end

  test "should fail destroying non existent todo" do
    assert_difference('Todo.count', 0) do
      delete todo_url(@bad_todo), as: :json
    end

    assert_response 404
  end

  test "should error with unprocesable " do
    assert_no_difference('Item.count') do
      post todos_url, params: { todo: { created_by: nil, title: nil } }, as: :json
    end
    assert_response 422
  end
end
