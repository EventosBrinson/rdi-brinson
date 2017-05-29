class Document < ApplicationRecord
  belongs_to :client
  has_attached_file :file

  validates :title, presence: true
  validates :client, presence: true
  validates_attachment :file, presence: true, content_type: { content_type: ['image/jpeg', 'application/pdf'] }
end
