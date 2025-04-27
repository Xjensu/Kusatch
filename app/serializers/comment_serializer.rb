class CommentSerializer
  include FastJsonapi::ObjectSerializer
  
  attribute :text do |object|
    Rails.cache.fetch("comment/#{object.id}/text", expires_in: 1.hour) do
      object.text
    end
  end
  
  attribute :commentator do |object|
    Rails.cache.fetch("user/#{object.user_id}/username", expires_in: 1.day) do
      object.user.username
    end
  end
end