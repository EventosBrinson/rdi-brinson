class CreateRents < ActiveRecord::Migration[5.1]
  def change
    create_table  :rents do |t|
      t.datetime  :delivery_time,             null: false
      t.datetime  :pick_up_time,              null: false
      t.text      :product,                   null: false
      t.decimal   :price,                     null: false
      t.decimal   :discount
      t.decimal   :additional_charges
      t.text      :additional_charges_notes
      t.text      :cancel_notes
      t.integer   :rent_type,                 null: false
      t.integer   :status,                    null: false

      t.references :client, foreign_key: true, index: true
      t.references :place, foreign_key: true, index: true
      t.references :creator, references: :users, index: true

      t.timestamps
    end

    add_foreign_key :rents, :users, column: :creator_id
  end
end
