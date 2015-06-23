class RenameTypeToHardwareType < ActiveRecord::Migration
  def change
    rename_column :hardwares, :type, :hardware_type
  end
end
