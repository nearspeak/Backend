class CreateTagCategories < ActiveRecord::Migration
  def change
    create_table :tag_categories do |t|
      t.integer :customer_id
      t.string :public_id
      t.string :name
      t.string :subline
      t.string :description
      t.string :image

      t.timestamps
    end
  end
end
