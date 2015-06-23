class CreateHardwareLocations < ActiveRecord::Migration
  def change
    create_table :hardware_locations do |t|
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
