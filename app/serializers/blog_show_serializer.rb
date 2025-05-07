class BlogShowSerializer
  include FastJsonapi::ObjectSerializer
  
  set_type :blog
  attributes :user_id, :title, :description, :content
  
  attribute :created_at do |object|
    object.created_at.strftime("%Y-%m-%d")
  end
  
  belongs_to :user, serializer: BlogUserSerializer
  has_many :comments, serializer: CommentSerializer
end