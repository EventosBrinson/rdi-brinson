class User < ApplicationRecord
  include Filterable
  include Orderable
  include Paginatable
  ROLES = [:staff, :admin, :user]

  has_many :clients, foreign_key: 'creator_id'
  has_many :places, through: :clients

  validates :username, presence: true
  validates :username, uniqueness: true
  validates :username, format: { with: /\A[^@]+\z/i }
  validates :email, presence: true
  validates :email, uniqueness: true
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }
  validates :firstname, presence: true
  validates :lastname, presence: true
  validates :role, presence: true
  validates :password, length: { in: 8..256 }, allow_nil: true

  has_secure_password validations: false
  enum role: ROLES

  scope :search, -> (query) { where('LOWER("users"."firstname") like :query OR LOWER("users"."lastname") like :query OR LOWER("users"."username") like :query OR LOWER("users"."email") like :query', query: "%#{ query.to_s.downcase }%") }

  def self.find_by_credential(credential)
    where('"users"."email" = :credential OR "users"."username" = :credential', credential: credential).first
  end

  def confirmed?
    !confirmed_at.nil?
  end

  def fullname
    [firstname, lastname].join(' ')
  end

  def pending?
    !confirmation_token.nil? and !confirmation_sent_at.nil?
  end

  def reset_password_requested?
    !reset_password_token.nil? and !reset_password_sent_at.nil?
  end

  def password=(unencrypted_password)
    if unencrypted_password.nil?
      self.password_digest = nil
    else
      @password = unencrypted_password
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
      self.password_digest = BCrypt::Password.create(unencrypted_password, cost: cost)
    end
  end
end
