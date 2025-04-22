class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :username
      t.string :email, null: false, index: { unique: true }
      t.string :encrypted_password, null: false
      t.boolean :is_moderator, default: false

      t.timestamps
    end
    
  end
end
