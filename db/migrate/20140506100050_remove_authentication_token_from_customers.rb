class RemoveAuthenticationTokenFromCustomers < ActiveRecord::Migration
  def change
    remove_column :customers, :authentication_token
  end
end
