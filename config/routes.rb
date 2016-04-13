Rails.application.routes.draw do
  mount Knock::Engine => "/knock"
  jsonapi_resources :public_posts
  jsonapi_resources :private_posts
end
