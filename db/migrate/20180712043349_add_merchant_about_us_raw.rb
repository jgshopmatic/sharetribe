class AddMerchantAboutUsRaw < ActiveRecord::Migration[5.1]
  def change
    add_column :people, :about_us_raw, :binary, :limit => 1.megabyte
  end
end
