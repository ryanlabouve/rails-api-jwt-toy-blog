require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    @valid_user = users(:valid)
  end

  test "User has correct attributes" do
    assert @valid_user.respond_to?(:name)
    assert @valid_user.respond_to?(:password_digest)
    assert @valid_user.respond_to?(:email)
  end

  test "invalid without name" do
    @valid_user.name = nil
    assert_not @valid_user.valid?
  end

  test "invalid without password and password_confirmation" do
  end

  test "invalid without email" do
    @valid_user.email= nil
    assert_not @valid_user.valid?
  end
end
