class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :username, null: false
      t.string :email, null: false, default: "", index: { unique: true }
      t.string :encrypted_password, null: false, default: ""
      t.boolean :is_moderator, default: false

      t.timestamps
    end

    add_index :users, :username, unique: true
  end
end

