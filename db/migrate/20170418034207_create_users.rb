class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string    :username,                null: false
      t.string    :email,                   null: false
      t.string    :password_digest,         null: false
      t.string    :firstname,               null: false
      t.string    :lastname,                null: false
      t.string    :role,                    null: false
      t.string    :reset_password_token
      t.datetime  :reset_password_sent_at
      t.string    :confirmation_token
      t.datetime  :confirmed_at
      t.datetime  :confirmation_sent_at

      t.timestamps null: false
    end

    add_index :users, :username,             unique: true
    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :confirmation_token,   unique: true
  end
end
