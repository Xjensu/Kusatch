class Comment < ApplicationRecord
  belongs_to :blog, counter_cache: true
  belongs_to :user

  belongs_to :parent_comment, class_name: 'Comment', optional: true
  has_many :comments, foreign_key: :parent_comment_id, dependent: :destroy

  validates :blog_id, presence: true
  validates :user_id, presence: true
  validates :text, presence: true

  def all_children
    comments.flat_map { |comment| [comment] + comment.all_children }
  end
end
