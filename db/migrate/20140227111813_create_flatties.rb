class CreateFlatties < ActiveRecord::Migration
  def change
    create_table :flatties do |t|

      t.timestamps
    end
  end
end
