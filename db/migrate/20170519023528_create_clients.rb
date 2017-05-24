class CreateClients < ActiveRecord::Migration[5.0]
  def change
    create_table :clients do |t|
      t.string    :firstname,        null: false
      t.string    :lastname,         null: false
      t.string    :address_line_1,   null: false
      t.string    :address_line_2
      t.string    :telephone_1,      null: false
      t.string    :telephone_2
      t.string    :id_name,          null: false
      t.integer   :trust_level,      null: false, default: 10
      t.boolean   :active,           null: false, default: true

      t.references :creator, references: :users, index: true
 
      t.timestamps null: false
    end

    add_foreign_key :clients, :users, column: :creator_id
  end
end
