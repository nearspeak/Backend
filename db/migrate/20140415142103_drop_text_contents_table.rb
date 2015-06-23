class DropTextContentsTable < ActiveRecord::Migration
  def change
    drop_table :text_contents
  end
end
