class AddHardwareToHardwareLocations < ActiveRecord::Migration
  def change
    change_table :hardware_locations do |t|
      t.references :hardware
    end
  end
end