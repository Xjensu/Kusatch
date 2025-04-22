class BlogUserSerializer 
  include FastJsonapi::ObjectSerializer

  set_type :user
  attributes :username
end
