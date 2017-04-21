class User < ApplicationRecord
  ROLES = [:admin, :staff]

  validates :username, presence: true
  validates :username, uniqueness: true
  validates :username, format: { with: /\A[a-zA-Z0-9]+\z/i }
  validates :email, presence: true
  validates :email, uniqueness: true
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }
  validates :firstname, presence: true
  validates :lastname, presence: true
  validates :role, presence: true
  validates :password, length: { in: 8..256 }, allow_nil: true

  has_secure_password validations: false
  enum role: ROLES

  def self.find_by_credential(credential)
    where('"users"."email" = :credential OR "users"."username" = :credential', credential: credential).first
  end

  def fullname
    [firstname, lastname].join(' ')
  end
end
