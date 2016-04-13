require 'test_helper'

class PrivatePostsControllerTest < ActionController::TestCase
  setup do
    @private_post = posts(:private_post)
  end

  def set_content_type_header!
    @request.headers['Content-Type'] = JSONAPI::MEDIA_TYPE
  end

  def authenticate
    token = Knock::AuthToken.new(payload: { sub: users(:valid).id }).token
    request.env['HTTP_AUTHORIZATION'] = "Bearer #{token}"
  end

  test "GET /private-posts" do
    p = @private_post
    get :index
    assert_response :unauthorized
  end

  test "GET /private-posts authed" do
    authenticate
    p = @private_post
    get :index
    assert_response :success
  end

  test "GET /private-posts/:id" do
    p = @private_post
    get :show, { id: p.id }
    assert_response :unauthorized
  end

  test "GET /private-posts/:id authed" do
    authenticate
    p = @private_post
    get :show, { id: p.id }
    assert_response :success
  end

  test "POST /private-post" do
    set_content_type_header!
    data = {
      data: {
        type: 'private-posts',
        attributes: {
          title: 'JR is Great',
          body: 'JSONAPIResources is the greatest thing since unsliced bread.'
        }
      }
    }
    assert_raises (ActionController::UrlGenerationError) {
      post :create, data
    }
  end

  test "UPDATE /private-post" do
    # TODO
  end

  test "DELETE /private-posts" do
    # TODO
  end
end
