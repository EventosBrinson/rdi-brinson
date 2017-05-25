class Client < ApplicationRecord
  include Activable
  include Filterable
  include Orderable
  include Paginatable

  ID_NAMES = ['ine', 'licencia', 'cartilla', 'pasaporte', 'otra']

  validates :firstname, presence: true
  validates :lastname, presence: true
  validates :address_line_1, presence: true
  validates :telephone_1, presence: true
  validates :id_name, presence: true
  validates :id_name, inclusion: { in: ID_NAMES }
  validates :trust_level, presence: true
  validates :trust_level, inclusion: { in: (1..10).to_a }

  scope :search, -> (query) { where('LOWER("clients"."firstname") like :query OR LOWER("clients"."lastname") like :query OR LOWER("clients"."address_line_1") like :query OR LOWER("clients"."address_line_2") like :query', query: "%#{ query.to_s.downcase }%") }
end
