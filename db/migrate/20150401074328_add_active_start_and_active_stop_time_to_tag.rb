class AddActiveStartAndActiveStopTimeToTag < ActiveRecord::Migration
  def change
    add_column :tags, :active_start_time, :time
    add_column :tags, :active_stop_time, :time
  end
end
