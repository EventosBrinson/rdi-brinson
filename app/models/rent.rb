class Rent < ApplicationRecord
  include Filterable
  include Orderable
  include Paginatable

  STATUSES = [:reserved, :on_route, :delivered, :on_pick_up, :pending, :finalized]
  STATUSES_VALUES = { reserved: 0, on_route: 1, delivered: 2, on_pick_up: 3, pending: 4, finalized: 5 }

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
  validate :status_transition, on: :update

  enum rent_type: Client::RENT_TYPES
  enum status: STATUSES

  before_validation :set_rent_type_from_client
  before_validation :init_status, on: :create

  scope :search, -> (query) { where('LOWER("rents"."product") like :query OR LOWER("rents"."additional_charges_notes") like :query', query: "%#{ query.to_s.downcase }%") }

  private

  def set_rent_type_from_client
    self.rent_type = client.rent_type if client
  end

  def init_status
    self.status = :reserved
  end

  def status_transition
    if status_changed?
      if status_was == 'finalized'
        errors.add(:status, "can't return to any status")
      elsif STATUSES_VALUES[status.to_sym] < STATUSES_VALUES[status_was.to_sym] and status != 'on_pick_up'
        errors.add(:status, "can't return to that status")
      end
    end
  end
end
