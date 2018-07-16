class AddColumnAffiliateUrlToListings < ActiveRecord::Migration[5.1]
  def change
    add_column :listings, :affiliate_url, :string, :default => ""
  end
end
