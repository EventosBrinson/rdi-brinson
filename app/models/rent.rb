class Rent < ApplicationRecord
  include Filterable
  include Orderable
  include Paginatable

  STATUSES = [:reserved, :on_route, :delivered, :on_pick_up, :pending, :finalized]

  belongs_to :client
  belongs_to :place
  belongs_to :creator, class_name: 'User'

  validates :delivery_time, presence: true
  validates :pick_up_time, presence: true
  validates :product, presence: true
  validates :price, presence: true
  validates_numericality_of :price, greater_than_or_equal_to: 0
  validates_numericality_of :discount, greater_than_or_equal_to: 0, allow_nil: true
  validates_numericality_of :additional_charges, greater_than_or_equal_to: 0, allow_nil: true
  validates :rent_type, presence: true
  validates :status, presence: true
  validates :client, presence: true
  validates :place, presence: true
  validates :creator, presence: true

  enum rent_type: Client::RENT_TYPES
  enum status: STATUSES

  before_validation :set_rent_type_from_client

  scope :search, -> (query) { where('LOWER("rents"."product") like :query OR LOWER("rents"."additional_charges_notes") like :query', query: "%#{ query.to_s.downcase }%") }

  private

  def set_rent_type_from_client
    self.rent_type = client.rent_type if client
  end
end
