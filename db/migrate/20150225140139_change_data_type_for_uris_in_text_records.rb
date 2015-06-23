class ChangeDataTypeForUrisInTextRecords < ActiveRecord::Migration
  def change
    change_column :text_records, :image_uri, :text
    change_column :text_records, :link_uri, :text
  end
end
