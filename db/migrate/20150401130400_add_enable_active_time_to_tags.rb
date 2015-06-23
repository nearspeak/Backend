class AddEnableActiveTimeToTags < ActiveRecord::Migration
  def change
    add_column :tags, :active_time, :boolean, default: false
  end
end
