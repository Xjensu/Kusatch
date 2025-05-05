class Blog < ApplicationRecord
  after_commit :invalidate_cache, on: [:create, :update, :destroy]
  after_touch :invalidate_cache

  belongs_to :user
  has_many :comments, -> { order(created_at: :asc) }, dependent: :destroy

  validates :user_id, presence: true
  validates :title, presence: true, length: { maximum: 255 }
  validates :description, presence: true
  validates :content, presence: true

  include PgSearch::Model
  pg_search_scope :search_by_content,
    against: [:title, :content],
    using: { tsearch: { prefix: true } }

  private

  def invalidate_cache
    RedisCache.pipelined do
      # Основные ключи блога
      delete_matched_keys("blog/#{id}-*")
      delete_matched_keys("blogs/index/*")
      
      # Кэш связанных данных
      RedisCache.del("user/#{user_id}/blogs")
      RedisCache.del("blog/#{id}/comments_tree")
      
      # Поисковый индекс
      RedisCache.del("search/blogs")
    end
    
    # Убрали user.touch чтобы избежать рекурсии
    # Вместо этого явно инвалидируем кэш пользователя
    RedisCache.del("user/#{user_id}")
    RedisCache.del("user/mini/#{user_id}")
  end

  def delete_matched_keys(pattern)
    RedisCache.scan_each(match: pattern) { |key| RedisCache.del(key) }
  end
end