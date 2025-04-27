class BlogSerializer
  include FastJsonapi::ObjectSerializer
  
  set_type :blog
  attributes :user_id, :title, :description, :created_at
  
  attribute :author do |object|
    { username: object.user.username }
  end
  
end
