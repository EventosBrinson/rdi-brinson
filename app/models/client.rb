class Client < ApplicationRecord
  include Activable
  include Filterable
  include Orderable
  include Paginatable

  ID_NAMES = ['ine', 'licencia', 'cartilla', 'pasaporte', 'otra']
  RENT_TYPES = [:first_rent, :frecuent, :business]
  FORMATED_RENT_TYPES =  { first_rent: 'Primera renta', frecuent: 'Frecuente', business: 'Empresa' }

  belongs_to :creator, class_name: 'User'
  has_many :documents
  has_many :places
  has_many :rents

  validates :firstname, presence: true
  validates :lastname, presence: true
  validates :street, presence: true
  validates :outer_number, presence: true
  validates :neighborhood, presence: true
  validates :telephone_1, presence: true
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }, allow_blank: true
  validates :id_name, presence: true
  validates :id_name, inclusion: { in: ID_NAMES }
  validates :trust_level, presence: true
  validates :trust_level, inclusion: { in: (1..10).to_a }
  validates :rent_type, presence: true
  validates :creator, presence: true

  enum rent_type: RENT_TYPES

  scope :search, -> (query) { where('LOWER("clients"."firstname") like :query OR LOWER("clients"."lastname") like :query OR LOWER("clients"."street") like :query OR LOWER("clients"."neighborhood") like :query', query: "%#{ query.to_s.downcase }%") }

  def folio
    "AGS-#{id + 260786}"
  end

  def fullname
    [firstname, lastname].join(' ')
  end

  def create_first_place
    Place.create(name: 'Domicilio por defecto',
                 street: self.street,
                 outer_number: self.outer_number,
                 inner_number: self.inner_number,
                 neighborhood: self.neighborhood,
                 postal_code: self.postal_code,
                 client: self)
  end

  def formated_rent_type
    FORMATED_RENT_TYPES[rent_type.to_sym]
  end

end
