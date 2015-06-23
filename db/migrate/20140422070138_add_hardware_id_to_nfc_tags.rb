class AddHardwareIdToNfcTags < ActiveRecord::Migration
  def change
    change_table :nfc_tags do |t|
      t.string :hardware_identifier
    end
  end
end
