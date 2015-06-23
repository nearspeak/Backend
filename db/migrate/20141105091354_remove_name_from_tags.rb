class RemoveNameFromTags < ActiveRecord::Migration
  def up
    remove_column :tags, :name
  end

  def down
    add_column :tags, :name, :string
  end
end
