class BlogStaticSerializer
  include FastJsonapi::ObjectSerializer
  
  set_type :blog
  attributes :id, :title, :description, :content
  
  attribute :author do |object|
    Rails.cache.fetch("user/#{object.user_id}/mini", expires_in: 1.hour) do
      UserMiniSerializer.new(object.user).as_json
    end
  end
end