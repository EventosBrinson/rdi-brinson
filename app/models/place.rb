class Place < ApplicationRecord
  include Activable
  include Filterable
  include Orderable
  include Paginatable

  belongs_to :client
  has_many :rents

  validates :name, presence: true
  validates :street, presence: true
  validates :inner_number, presence: true
  validates :outer_number, presence: true
  validates :neighborhood, presence: true
  validates :postal_code, presence: true
  validates :client, presence: true

  scope :search, -> (query) { where('LOWER("places"."name") like :query OR LOWER("places"."street") like :query OR LOWER("places"."neighborhood") like :query', query: "%#{ query.to_s.downcase }%") }
end
