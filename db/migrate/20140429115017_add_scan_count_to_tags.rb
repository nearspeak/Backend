class AddScanCountToTags < ActiveRecord::Migration
  def change
    add_column :tags, :scan_count, :integer
  end
end
