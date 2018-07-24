class AddMerchantDetails < ActiveRecord::Migration[5.1]
  def change
    add_column :people, :merchant_id, :bigint, :default => 0
    add_column :people, :merchant_name, :string, :default => ""
    add_column :people, :merchant_canonical_name, :string, :default => ""
    add_column :people, :merchant_status, :int, :default => 0
    add_column :people, :merchant_salesforce_id, :string, :default => ""
    add_column :people, :merchant_notification_email, :string, :default => ""
    add_column :people, :domain_id, :bigint, :default => 0
    add_column :people, :domain_fqdn, :string, :default => ""
    add_column :people, :domain_status, :int, :default => 0
    add_column :people, :domain_active, :boolean, :default => true
    add_column :people, :site_id, :bigint, :default => 0
    add_column :people, :site_cover_image, :string, :default => ""
    add_column :people, :site_logo, :string, :default => ""
    add_column :people, :site_about_us, :text
    add_column :people, :site_url, :string, :default => ""
    add_column :people, :contact_us_url, :string, :default => ""
    add_column :people, :product_url, :string, :default => ""
  end
end
