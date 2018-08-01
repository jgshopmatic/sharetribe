class AddMerchantShippingDetails < ActiveRecord::Migration[5.1]
  def change
    add_column :people, :merchant_shipping, :string, :default => ""
  end
end
