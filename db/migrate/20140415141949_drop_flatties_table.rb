class DropFlattiesTable < ActiveRecord::Migration
  def change
    drop_table :flatties
  end
end
