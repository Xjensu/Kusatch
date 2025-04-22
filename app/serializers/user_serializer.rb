class UserSerializer 
  include FastJsonapi::ObjectSerializer

  set_type :user
  attributes :id, :username, :first_name, :last_name
  
  has_many  :blogs, serializer: BlogSerializer
end
