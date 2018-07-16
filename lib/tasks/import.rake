#lib/tasks/import.rake
require 'csv'
require 'byebug'
require 'net/http'
require 'json'
desc "Imports a CSV file into an ActiveRecord table"
task :import, [:filename] => :environment do
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