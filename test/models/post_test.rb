require 'test_helper'

class PostTest < ActiveSupport::TestCase

  setup do
    @valid_post = posts(:valid)
    @public_post = posts(:public_post)
    @private_post = posts(:private_post)
  end

  test "Post has the correct attributes" do
    assert @valid_post.respond_to?(:title)
    assert @valid_post.respond_to?(:body)
    assert @valid_post.respond_to?(:type)
  end

  test "valid post is valid" do
    assert @valid_post.valid?
  end

  test "valid public post is valid" do
    assert @public_post.valid?
  end

  test "valid private post is valid" do
    assert @private_post.valid?
  end

  test "post of invalid type is invalid" do
    @public_post.type = 'PoopyBottom'
    assert_not @public_post.valid?
  end

  test "Post requires all fields" do
    @valid_post.title = nil
    @valid_post.body= nil
    @valid_post.type = nil
    assert_equal @valid_post.save(), false, 'Post with no attributes should not save'
  end

  test "requires title" do
    @valid_post.title = nil
    assert_not @valid_post.valid?
  end

  test "requires body" do
    @valid_post.body = nil
    assert_not @valid_post.valid?
  end

  test "requires type" do
    @valid_post.type = nil
    assert_not @valid_post.valid?
  end
end
