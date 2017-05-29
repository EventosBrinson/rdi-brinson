class AddAttachmentFileToDocuments < ActiveRecord::Migration[5.1]
  def change
    add_attachment :documents, :file
  end
end
