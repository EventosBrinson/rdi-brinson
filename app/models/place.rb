class Place < ApplicationRecord
  include Activable
  include Filterable
  include Orderable
  include Paginatable

  belongs_to :client

  validates :name, presence: true
  validates :address_line_1, presence: true
  validates :client, presence: true

  scope :search, -> (query) { where('LOWER("places"."name") like :query OR LOWER("places"."address_line_1") like :query OR LOWER("places"."address_line_2") like :query', query: "%#{ query.to_s.downcase }%") }
end
