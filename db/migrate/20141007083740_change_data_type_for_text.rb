class ChangeDataTypeForText < ActiveRecord::Migration
  def up
    change_table :translations do |t|
      t.change :text, :text
    end
  end

  def down
    change_table :translations do |t|
      t.change :text, :string
    end
  end
end
