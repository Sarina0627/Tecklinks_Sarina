class CreateBookmarks < ActiveRecord::Migration[5.2]
  def change
    create_table :bookmarks do |t|
      t.string :title
      t.string :url
      t.string :tag
      t.integer :user_id
      t.integer :fav
      t.timestamps null: false
    end
  end
end
