class CreatePlaces < ActiveRecord::Migration[5.1]
  def change
    create_table :places do |t|
      t.string    :name,        null: false
      t.string    :address_line_1,   null: false
      t.string    :address_line_2
      t.decimal   :latitude, precision: 10, scale: 6
      t.decimal   :longitude, precision: 10, scale: 6
      t.boolean   :active,           null: false, default: true

      t.references :client, foreign_key: true, index: true

      t.timestamps
    end
  end
end
