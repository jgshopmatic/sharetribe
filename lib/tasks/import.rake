#lib/tasks/import.rake
require 'csv'
require 'byebug'
require 'net/http'
require 'json'
desc "Imports a CSV file into an ActiveRecord table"
task :import, [:filename] => :environment do

  mproducts = ActiveRecord::Base.connection.execute("select  mp.name, mp.description, mp.price, mp.image_1, mp.image_2, mp.image_3, mp.image_4, mp.slug, mp.fqdn, p.username, p.merchant_category from merchant_products mp, people p where mp.tenant_id = p.merchant_id ")

  mproducts.each do |row|
    make_post_req({
                      :listing=>{
                          :title=> row[0],
                          :price=>row[2],
                          :shipping_price=>"0",
                          :shipping_price_additional=>"0",
                          :delivery_methods=>["pickup"],
                          :description=>row[1],
                          :category=>row[10],
                          :listing_shape=>"products",
                          :images=> [row[3], row[4], row[5], row[6]],
                          :affiliate_url => "https://#{row[8]}/products/#{row[7]}",
                          :username => row[9]
                      }
                  })
  end
end


def make_post_req(data)
  require 'net/http'
  require 'json'
  begin
    uri = URI('https://dev.goshopmatic.com/api/v1/listings')
    http = Net::HTTP.new(uri.host, uri.port, "localhost", "8888")
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

=begin
#file = '/home/gaurav/app/sharetribe/shared/InternalMerchantData_updated.xlsx - M1Products.csv'
file = '/Users/jideshgopalan/Downloads/mdata/InternalMerchantData_updated.xlsx - M1Products.csv'

CSV.foreach(file, :headers => true) do |row|
  make_post_req({
                    :listing=>{
                        :title=> row[1],
                        :price=>row[5],
                        :shipping_price=>"0",
                        :shipping_price_additional=>"0",
                        :delivery_methods=>["pickup"],
                        :description=>row[4],
                        :category=>row[23],
                        :listing_shape=>"products",
                        :images=> row[13].strip.split(',').collect {|x| x.strip },
                        :affiliate_url => "https://#{row[23]}.myshopmatic.com/products/#{row[14]}",
                        :username => row[22]
                    }
                })
end=end
