class BlogShowSerializer
  include FastJsonapi::ObjectSerializer
  
  set_type :blog
  attributes :user_id, :title, :description, :content, :created_at
  
  belongs_to :user, serializer: BlogUserSerializer
  has_many :comments, serializer: CommentSerializer

end