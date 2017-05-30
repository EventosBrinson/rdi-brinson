require 'rails_helper'

RSpec.describe Document, type: :model do
  subject { FactoryGirl.build :document }

  it { should have_db_column(:title).of_type(:string).with_options(null: false) }

  it { should belong_to(:client) }
  it { should have_attached_file(:file) }

  it { should validate_presence_of :title }
  it { should validate_presence_of :title }
  it { should validate_presence_of :client }
  it { should validate_attachment_presence(:file) }
  it { should validate_attachment_content_type(:file)
              .allowing('image/jpeg', 'application/pdf')
              .rejecting('text/plain', 'text/xml') }
end
