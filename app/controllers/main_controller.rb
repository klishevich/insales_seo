require 'net/http'

class MainController < ApplicationController
  def index
  end

 #  def put_product
 #  	product_id = params[:id]
 #  	product_title = params[:title]
 #  	my_subdomain = @account.insales_subdomain
 #  	my_pass = @account.password
 #  	my_url = "http://" + my_subdomain + "/admin/products/" + product_id + ".json"
	# Rails.logger.info( 'my_url:' )
	# Rails.logger.info(my_url)
	# json_data = {
 #    	"id" => product_id,
 #    	"title" => product_title
 #    	}.to_json
	# uri = URI.parse(my_url)
	# request = Net::HTTP::Put.new uri.path
	# Rails.logger.info(' Request body: ')
	# request.body = json_data
	# Rails.logger.info(json_data)
	# request.content_type = 'application/json'
	# request.basic_auth 'mrjones', my_pass
	# response = Net::HTTP.new(uri.host, uri.port).start { |http| http.request request }
	# Rails.logger.info( 'response body:' )
	# Rails.logger.info(response.body)
	# @myresult = response.body
 #  end

  def seo_filters_update
  	sfu = SeoFiltersUpdate.new
  	sfu.account = @account
	collection_filters = sfu.get_collection_filters
	collections = sfu.get_collections
	collection_filters.each do |el|
		temp = el['collection_id']
		# puts temp
		# puts collections
		# puts collections[0]
		el['url']=collections[temp]+ '/' + el['permalink']
	end
	puts collection_filters
	products = sfu.get_products
    # puts products
    puts products.count
    puts products.first
    puts sfu.filter_products(1482648,'1')
  end

end
