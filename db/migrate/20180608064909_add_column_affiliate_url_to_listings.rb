class AddColumnImagesToListings < ActiveRecord::Migration[5.1]
  def change
    add_column :listings, :image_urls, :string, :default => ""
  end
end
