#lib/tasks/import.rake
require 'csv'
require 'byebug'
require 'net/http'
require 'json'
desc "Imports a CSV file into an ActiveRecord table"
task :import, [:filename] => :environment do
  mproducts = ActiveRecord::Base.connection.execute("select  mp.name, mp.description, mp.price, mp.image_1, mp.image_2, mp.image_3, mp.image_4, mp.slug, mp.fqdn, p.username, p.merchant_category from merchant_products mp, people p where mp.tenant_id = p.merchant_id ")

  mproducts.each do |row|
    images =  [row[3], row[4], row[5], row[6]].compact.select {|item| item!=""}
    data = {
                      :listing=>{
                          :title=> row[0],
                          :price=>row[2],
                          :shipping_price=>"0",
                          :shipping_price_additional=>"0",
                          :delivery_methods=>["pickup"],
                          :description=>row[1],
                          :category=>row[10],
                          :listing_shape=>"products",
                          :images=> images,
                          :affiliate_url => "https://#{row[8]}/products/#{row[7]}",
                          :username => row[9]
                      }
                  }
    begin
      uri = URI('https://dev.goshopmatic.com/api/v1/listings')
      http = Net::HTTP.new(uri.host, uri.port)
      req = Net::HTTP::Post.new(uri.path, {'Content-Type' =>'application/json', 'Authorization' => 'XXXXXXXXXXXXXXXX'})
      http.use_ssl = true
      req.body = data.to_json
      puts ("------------- \n ")
      puts(req.body)
      puts("-------------- \n")
      res = http.request(req)
      puts JSON.parse(res.status)
    rescue => e
      puts "failed #{e}"
    end
  end
end


