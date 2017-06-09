class Rent < ApplicationRecord
  STATUSES = [:reserved, :on_route, :delivered, :on_pick_up, :pending, :finalized]

  belongs_to :client
  belongs_to :place
  belongs_to :creator, class_name: 'User'

  validates :delivery_time, presence: true
  validates :pick_up_time, presence: true
  validates :product, presence: true
  validates :price, presence: true
  validates_numericality_of :price, greater_than_or_equal_to: 0
  validates_numericality_of :discount, greater_than_or_equal_to: 0
  validates_numericality_of :additional_charges, greater_than_or_equal_to: 0
  validates :rent_type, presence: true
  validates :status, presence: true
  validates :client, presence: true
  validates :place, presence: true
  validates :creator, presence: true

  enum rent_type: Client::RENT_TYPES
  enum status: STATUSES
end
