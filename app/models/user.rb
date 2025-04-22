class User < ApplicationRecord
  has_secure_password
  has_many :blogs, dependent: :destroy
  has_many :comments, dependent: :destroy

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :username, presence: true, uniqueness: true

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 6 }, on: :create

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  def full_name
    "#{first_name} #{last_name}"
  end
  
  def invalidate_all_refresh_tokens!
    refresh_tokens.delete_all
  end
end
