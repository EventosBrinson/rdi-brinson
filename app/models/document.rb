class Document < ApplicationRecord
  belongs_to :client
  has_attached_file :file, styles: { thumb: "200x200>" }, :path => ":rails_root/storage/#{Rails.env}#{ENV['RAILS_TEST_NUMBER']}/:class/:attachment/:id_partition/:style/:filename"

  validates :title, presence: true
  validates :client, presence: true
  validates_attachment :file, presence: true, content_type: { content_type: ['image/jpeg', 'application/pdf'] }

  def set_file_from(params:)
    self.file = params[:data]
    self.file_file_name = params[:filename]
  end
end
