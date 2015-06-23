class AddDateBasedFeatureToTags < ActiveRecord::Migration
  def change
    add_column :tags, :active_date, :boolean, default: false
    add_column :tags, :active_start_date, :date
    add_column :tags, :active_stop_date, :date
  end
end
