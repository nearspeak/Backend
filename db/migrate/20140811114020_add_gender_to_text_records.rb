class AddGenderToTextRecords < ActiveRecord::Migration
  def change
    add_column :text_records, :gender, :string
  end
end
