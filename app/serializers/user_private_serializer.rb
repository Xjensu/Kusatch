class UserPrivateSerializer
  include FastJsonapi::ObjectSerializer
  
  set_type :user
  attributes :id, :username, :first_name, :last_name, :email
  has_many :blogs, serializer: BlogUserSerializer
end
