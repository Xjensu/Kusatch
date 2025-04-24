class CreateBlogs < ActiveRecord::Migration[8.0]
  def change
    create_table :blogs do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.string :description
      t.string :content

      t.timestamps
    end
    add_index :blogs, :created_at
    add_index :blogs, :title
  end
end
