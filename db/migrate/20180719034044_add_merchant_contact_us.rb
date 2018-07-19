class AddMerchantContactUs < ActiveRecord::Migration[5.1]
  def change
    add_column :people, :site_contact_us, :text
  end
end
