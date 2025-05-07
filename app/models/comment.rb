class Comment < ApplicationRecord
  after_commit :invalidate_cache, on: [:create, :update, :destroy]
  after_touch :invalidate_cache

  belongs_to :blog
  belongs_to :user
  belongs_to :parent_comment, class_name: 'Comment', optional: true
  has_many :comments, foreign_key: :parent_comment_id, dependent: :destroy

  validates :blog_id, presence: true
  validates :user_id, presence: true
  validates :text, presence: { message: "can't be blank" }

  def self.starts_with(column_name, prefix)
    where("lower(#{column_name}) like ?", "#{prefix.downcase}%")
  end

  private

  def invalidate_cache
    RedisCache.pipelined do
      # Основные ключи комментария
      RedisCache.del("comment/#{id}/full")
      
      # Полная инвалидация дерева комментариев блога
      delete_matched_keys("blog/#{blog_id}/comments_tree*")
      
      # Родительский комментарий
      RedisCache.del("comment/#{parent_comment_id}/full") if parent_comment_id.present?
      
      # Пользовательские данные
      RedisCache.del("user/#{user_id}/comments")
      
      # Инвалидация блога и пользователя
      RedisCache.del("blog/#{blog_id}")
      RedisCache.del("user/#{user_id}")
    end
    
    invalidate_parent_comment_chain if parent_comment_id.present?
  end

  def invalidate_parent_comment_chain
    current = parent_comment
    while current.present?
      RedisCache.del("comment/#{current.id}/full")
      current = current.parent_comment
    end
  end

  def delete_matched_keys(pattern)
    RedisCache.scan_each(match: pattern) { |key| RedisCache.del(key) }
  end
  
end