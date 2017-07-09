class ChangePlacePostalCodeToAdmitNull < ActiveRecord::Migration[5.1]
  def change
    change_column_null :places, :postal_code, true
  end
end
