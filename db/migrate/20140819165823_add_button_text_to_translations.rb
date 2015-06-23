class AddButtonTextToTranslations < ActiveRecord::Migration
  def change
    add_column :translations, :button_text, :string
  end
end
