class CreatePurchases < ActiveRecord::Migration
  def change
    create_table :purchases do |t|
      t.references :text_record
      t.string :purchase_id, :limit => 36

      t.timestamps
    end
  end
end
