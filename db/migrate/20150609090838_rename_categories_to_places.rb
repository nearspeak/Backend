class RenameCategoriesToPlaces < ActiveRecord::Migration
  def change
    rename_table :tag_categories, :places
    
    remove_column :places, :public_id
    remove_column :places, :subline
    remove_column :places, :image
  end
end
