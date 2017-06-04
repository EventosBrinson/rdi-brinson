require 'rails_helper'

RSpec.describe Document, type: :model do
  subject { FactoryGirl.build :document }

  it { should have_db_column(:title).of_type(:string).with_options(null: false) }

  it { should belong_to(:client) }
  it { should have_attached_file(:file) }

  it { should validate_presence_of :title }
  it { should validate_presence_of :client }
  it { should validate_attachment_presence(:file) }
  it { should validate_attachment_content_type(:file)
              .allowing('image/jpeg', 'application/pdf')
              .rejecting('text/plain', 'text/xml') }

  describe '#set_file_from' do
    it 'sets the filename and data form a hash' do
      document = Document.new

      document.set_file_from params: { filename: 'tiger.jpg', data: Constants::Images::BASE64_2x2 }

      expect(document.file_file_name).to eq 'tiger.jpg'
      expect(document.file_content_type).to eq 'image/jpeg'
    end
  end
end
