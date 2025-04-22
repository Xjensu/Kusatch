class Blog < ApplicationRecord
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

  after_commit :clear_cache

  def clear_cache
    Rails.cache.delete("blog/#{id}/with_associations/v1/#{updated_at.to_i}")
    Rails.cache.delete_matched("blogs/page:*")
  end

  def cache_key_with_version
    "#{cache_key}/#{updated_at.to_i}"
  end
end
