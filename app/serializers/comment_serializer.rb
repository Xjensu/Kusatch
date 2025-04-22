class CommentSerializer < ActiveModel::Serializer
  attributes :id, :text, :created_at, :user

  belongs_to :user, serializer: UserSerializer

  has_many :comments, serializer: CommentSerializer

  def user
    object.user
  end
end