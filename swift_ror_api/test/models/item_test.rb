require "test_helper"

class ItemTest < ActiveSupport::TestCase
  test "should not save todo without title" do
    item = Item.new
    assert_not item.save
  end
end
