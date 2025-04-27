class UserMiniSerializer
  include FastJsonapi::ObjectSerializer

  set_type :user
  attribute :username

end