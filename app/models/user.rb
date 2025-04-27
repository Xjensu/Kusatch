class User < ApplicationRecord
  after_commit :invalidate_cache, on: [:create, :update, :destroy]
  after_touch :invalidate_cache

  has_many :blogs, dependent: :destroy
  has_many :comments, dependent: :destroy

  validates :first_name, presence: true
  validates :last_name, presence: true

  validates :email, presence: { message: "can't be blank" },
                  uniqueness: { message: "has already been taken" },
                  format: { with: URI::MailTo::EMAIL_REGEXP, message: "is invalid" }

  validates :username, presence: { message: "can't be blank" },
                     uniqueness: { message: "has already been taken" }
  validates :password, presence: true, length: { minimum: 6 }, on: :create

  validates :password, confirmation: true, allow_blank: true

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  before_create :generate_confirmation_token

  attribute :admin, default: false


  def full_name
    "#{first_name} #{last_name}"
  end
  
  def confirm!
    update(confirmed_at: Time.now, confirmation_token: nil)
  end

  def confirmed?
    confirmed_at.present?
  end

  private

  def generate_confirmation_token
    self.confirmation_token = SecureRandom.urlsafe_base64
  end

  def invalidate_cache
    RedisCache.pipelined do
      # Основные ключи пользователя
      RedisCache.del_matched("user/#{id}/*")
      RedisCache.del("user/mini/#{id}")
      
      # Связанные данные
      RedisCache.del_matched("blogs/author/#{id}/*")
      RedisCache.del_matched("comments/author/#{id}/*")
    end
    
    # Каскадное обновление всех связанных записей
    blogs.find_each(&:touch) if persisted? && !destroyed?
    comments.find_each(&:touch) if persisted? && !destroyed?
  end
end
