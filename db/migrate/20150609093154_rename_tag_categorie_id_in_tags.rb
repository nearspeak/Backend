class RenameTagCategorieIdInTags < ActiveRecord::Migration
  def change
    rename_column :tags, :tag_category_id, :place_id
  end
end
