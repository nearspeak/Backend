class RemoveButtonTextFromTranslations < ActiveRecord::Migration
  def change
    remove_column :translations, :button_text
  end
end
