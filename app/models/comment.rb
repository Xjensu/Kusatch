class Comment < ApplicationRecord
  acts_as_nested_set scope: :blog, counter_cache: :comments_count

  after_commit :invalidate_cache, on: [:create, :update, :destroy]
  after_touch :invalidate_cache

  belongs_to :blog
  belongs_to :user
  belongs_to :parent_comment, class_name: 'Comment', optional: true
  has_many :comments, foreign_key: :parent_comment_id, dependent: :destroy

  validates :blog_id, presence: true
  validates :user_id, presence: true
  validates :text, presence: { message: "can't be blank" }

  private

  def invalidate_cache
    RedisCache.pipelined do
      # Основные ключи комментария
      RedisCache.del("comment/#{id}/full")
      RedisCache.del("blog/#{blog_id}/comments_tree")
      
      # Родительский комментарий
      RedisCache.del("comment/#{parent_comment_id}/full") if parent_comment_id.present?
      
      # Пользовательские данные
      RedisCache.del("user/#{user_id}/comments")
    end
    
    # Каскадное обновление блога и пользователя
    blog.touch if persisted? && !destroyed?
    user.touch if persisted? && !destroyed?
  end
end