class Place < ApplicationRecord
  include Activable
  include Filterable
  include Orderable
  include Paginatable

  belongs_to :client
  has_many :rents

  validates :name, presence: true
  validates :street, presence: true
  validates :outer_number, presence: true
  validates :neighborhood, presence: true
  validates :client, presence: true

  scope :search, -> (query) { where('LOWER("places"."name") like :query OR LOWER("places"."street") like :query OR LOWER("places"."neighborhood") like :query', query: "%#{ query.to_s.downcase }%") }

  def address
    "#{ street } ##{ outer_number }#{ inner_number ? ' Int. ' + inner_number : '' }, #{ neighborhood } #{ postal_code ? 'CP. ' + postal_code : '' }"
  end
end
