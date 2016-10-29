require 'test_helper'

class EmailTest < ActiveSupport::TestCase
  setup do
    @email = emails(:one)
  end

  test "Merge performs replacements in the body" do
    @email.merge
    assert_equal 'Dear Bob', @email.body
  end
end