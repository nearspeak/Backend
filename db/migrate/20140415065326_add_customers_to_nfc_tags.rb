class AddCustomersToNfcTags < ActiveRecord::Migration
  def change
    change_table :nfc_tags do |t|
      t.references :customer
    end
  end
end
