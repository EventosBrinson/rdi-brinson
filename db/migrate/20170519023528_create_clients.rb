class CreateClients < ActiveRecord::Migration[5.1]
  def change
    create_table :clients do |t|
      t.string    :firstname,         null: false
      t.string    :lastname,          null: false
      t.string    :street,            null: false
      t.string    :inner_number
      t.string    :outer_number,      null: false
      t.string    :neighborhood,      null: false
      t.string    :postal_code,       null: false
      t.string    :telephone_1,       null: false
      t.string    :telephone_2
      t.string    :email,             null: false
      t.string    :id_name,           null: false
      t.integer   :trust_level,       null: false, default: 10
      t.integer   :rent_type,         null: false
      t.boolean   :active,            null: false, default: true

      t.references :creator, references: :users, index: true
 
      t.timestamps null: false
    end

    add_foreign_key :clients, :users, column: :creator_id
  end
end
