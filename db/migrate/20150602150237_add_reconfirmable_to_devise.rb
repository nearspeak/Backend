class AddReconfirmableToDevise < ActiveRecord::Migration
  def up
    add_column :customers, :unconfirmed_email, :string # Only if using reconfirmable
  end

  def down
    remove_columns :customers, :unconfirmed_email # Only if using reconfirmable
  end
end
