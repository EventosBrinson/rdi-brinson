class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string    :username,                null: false
      t.string    :email,                   null: false
      t.string    :password_digest
      t.string    :firstname,               null: false
      t.string    :lastname,                null: false
      t.integer   :role,                    null: false
      t.boolean   :main,                    null: false, default: false
      t.string    :reset_password_token
      t.datetime  :reset_password_sent_at
      t.string    :confirmation_token
      t.datetime  :confirmed_at
      t.datetime  :confirmation_sent_at
      t.boolean   :active,                  null: false, default: true

      t.timestamps null: false
    end

    add_index :users, :username,             unique: true
    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :confirmation_token,   unique: true
  end
end
