class AddMajorMinorToHardwares < ActiveRecord::Migration
  def change
    add_column :hardwares, :major, :string
    add_column :hardwares, :minor, :string
  end
end
