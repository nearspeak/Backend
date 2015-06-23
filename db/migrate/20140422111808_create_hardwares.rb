class CreateHardwares < ActiveRecord::Migration
  def change
    create_table :hardwares do |t|
      t.string :identifier
      t.string :type
      t.belongs_to :tag

      t.timestamps
    end
  end
end
