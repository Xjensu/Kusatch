class CreateComments < ActiveRecord::Migration[8.0]
  def change
    create_table :comments do |t|
      t.references :blog, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :parent_comment, foreign_key: { to_table: :comments }
      t.string :text, null: false

      t.timestamps
    end
    add_index :comments, [:blog_id, :created_at]
  end
end
