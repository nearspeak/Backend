class CreateNfcTags < ActiveRecord::Migration
  def change
    create_table :nfc_tags do |t|
      t.references :tag_category

      t.string :name
      t.string :description
      t.string :tag_identifier

      t.timestamps
    end
  end
end
