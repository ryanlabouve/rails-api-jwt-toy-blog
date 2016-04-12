require 'test_helper'

class PublicPostsControllerTest < ActionController::TestCase
  setup do
    @public_post = posts(:public_post)
  end

  def set_content_type_header!
    @request.headers['Content-Type'] = JSONAPI::MEDIA_TYPE
  end

  test "GET /publics-posts" do
    p = @public_post
    get :index
    assert_response :success
  end

  test "GET /public-posts/:id" do
    p = @public_post
    get :show, { id: p.id }
    assert_response :success
  end

  test "POST /public-post" do
    set_content_type_header!
    data = {
      data: {
        type: 'public-posts',
        attributes: {
          title: 'JR is Great',
          body: 'JSONAPIResources is the greatest thing since unsliced bread.'
        }
      }
    }
    assert_raises (ActionController::UrlGenerationError) {
      post :create, data
    }
    # assert_response :created
  end

  test "UPDATE /public-post" do
    # TODO
  end

  test "DELETE /public-posts" do
    # TODO
  end
end
