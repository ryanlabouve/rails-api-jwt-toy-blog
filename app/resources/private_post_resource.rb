class PrivatePostResource < JSONAPI::Resource
  immutable
  attributes :title, :body
end
