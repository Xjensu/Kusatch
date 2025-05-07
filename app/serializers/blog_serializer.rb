class BlogSerializer
  include FastJsonapi::ObjectSerializer
  
  set_type :blog
  attributes :user_id, :title, :description
  
  attribute :created_at do |object|
    object.created_at.strftime("%Y-%m-%d")
  end
  
  attribute :author do |object|
    { username: object.user.username }
  end
end