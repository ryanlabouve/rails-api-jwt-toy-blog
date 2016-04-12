class PublicPostResource < JSONAPI::Resource
  immutable
  attributes :title, :body
end
