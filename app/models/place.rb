class Place < ApplicationRecord
  belongs_to :client

  validates :name, presence: true
  validates :address_line_1, presence: true
  validates :client, presence: true
end
