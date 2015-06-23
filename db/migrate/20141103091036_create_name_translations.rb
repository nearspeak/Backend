class CreateNameTranslations < ActiveRecord::Migration
  def change
    create_table :name_translations do |t|
      t.integer  :tag_id
      t.integer  :original_name_id
      t.string :lang_code
      t.text :text

      t.timestamps
    end
  end
end
