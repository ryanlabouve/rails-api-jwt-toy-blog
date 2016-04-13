class PrivatePostsController < ApplicationController
  include JSONAPI::ActsAsResourceController
  before_filter :authenticate
end
