class CreateTextRecords < ActiveRecord::Migration
  def change
    create_table :text_records do |t|
      t.references :tag

      t.string :image_uri, :limit => 512, :null => false, :default => ''
      t.string :link_uri, :limit => 512, :null => false, :default => ''

      t.timestamps
    end
  end
end
