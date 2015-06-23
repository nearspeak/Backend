class AddAncestryToTags < ActiveRecord::Migration
  def up
    add_column :tags, :ancestry, :string
    add_index :tags, :ancestry
  end
  
  def down
    remove_index :tags, :ancestry
    remove_column :tags, :ancestry
  end
end
