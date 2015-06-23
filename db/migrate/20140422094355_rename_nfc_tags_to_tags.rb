class RenameNfcTagsToTags < ActiveRecord::Migration
  def change
    rename_table :nfc_tags, :tags
  end
end
