class CreateTranslations < ActiveRecord::Migration
  def change
    create_table :translations do |t|
      t.references :text_record
      t.integer :original_text_id

      t.string :lang_code
      t.string :text

      t.timestamps
    end
  end
end
