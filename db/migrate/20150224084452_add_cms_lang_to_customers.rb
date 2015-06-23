class AddCmsLangToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :cms_lang, :string
  end
end
