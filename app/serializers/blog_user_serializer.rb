class BlogUserSerializer
  include FastJsonapi::ObjectSerializer
  
  set_type :blog
  attributes :user_id, :title, :description, :created_at

  attribute :user_id do |object|
    Rails.cache.fetch("blog/#{object.id}/user_id") { object.user_id }
  end
end