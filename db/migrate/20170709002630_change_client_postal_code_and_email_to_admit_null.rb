class ChangeClientPostalCodeAndEmailToAdmitNull < ActiveRecord::Migration[5.1]
  def change
    change_column_null :clients, :postal_code, true
    change_column_null :clients, :email, true
  end
end
