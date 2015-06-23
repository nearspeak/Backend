class RemoveHardwareIdentifier < ActiveRecord::Migration
  def change
    remove_column :tags, :hardware_identifier
  end
end
