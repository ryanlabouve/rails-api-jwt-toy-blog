class Post < ActiveRecord::Base
  validates :body, presence: true
  validates :title, presence: true
  validates :type, presence: true

  POST_TYPES = %w(PublicPost PrivatePost)
  validates :type, :inclusion => { :in => POST_TYPES }
end
