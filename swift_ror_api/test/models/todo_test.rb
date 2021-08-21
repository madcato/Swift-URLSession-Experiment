require "test_helper"

class TodoTest < ActiveSupport::TestCase
  test "should not save todo without title" do
    todo = Todo.new
    assert_not todo.save
  end
end
