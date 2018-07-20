class AddMerchantCategory < ActiveRecord::Migration[5.1]
  def change
    add_column :people, :merchant_category, :string, :default => ""
  end
end
