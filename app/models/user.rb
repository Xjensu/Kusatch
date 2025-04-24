class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :blogs, dependent: :destroy
  has_many :comments, dependent: :destroy

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :username, presence: true, uniqueness: true

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 6 }, on: :create

  validates :password, confirmation: true, allow_blank: true
  validate :current_password_is_correct, if: :password_changed?

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  def full_name
    "#{first_name} #{last_name}"
  end
  
  def invalidate_all_refresh_tokens!
    refresh_tokens.delete_all
  end

  def current_password_is_correct
    return if current_password.blank? || valid_password?(current_password)

    errors.add(:current_password, 'is incorrect')
  end

  def password_changed?
    encrypted_password_changed?
  end
end
