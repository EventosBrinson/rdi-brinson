class CreateDocuments < ActiveRecord::Migration[5.1]
  def change
    create_table :documents do |t|
      t.string :title, null: false
      t.references :client, foreign_key: true, index: true

      t.timestamps
    end
  end
end
