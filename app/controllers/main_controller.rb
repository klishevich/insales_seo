require 'net/http'

class MainController < ApplicationController
  def index
  end

  def get_products
  	my_subdomain = @account.insales_subdomain
  	my_pass = @account.password
  	my_url = "http://" + my_subdomain + "/admin/products.json"
	Rails.logger.info( 'my_url:' )
	Rails.logger.info(my_url)
  	# xml_data = %{<?xml version="1.0" encoding="UTF-8"?>}
	uri = URI.parse(my_url)
	request = Net::HTTP::Get.new uri.path
	# request.body = xml_data
	# request.content_type = 'text/xml'
	request.basic_auth 'mrjones', my_pass
	response = Net::HTTP.start(uri.host, uri.port) {|http| http.request(request)}
	Rails.logger.info( 'response body:' )
	Rails.logger.info(response.body)
	@myresult = response.body
  end

  def put_product
  	product_id = params[:id]
  	product_title = params[:title]
  	my_subdomain = @account.insales_subdomain
  	my_pass = @account.password
  	my_url = "http://" + my_subdomain + "/admin/products/" + product_id + ".json"
	Rails.logger.info( 'my_url:' )
	Rails.logger.info(my_url)
	json_data = {
    	"id" => product_id,
    	"title" => product_title
    	}.to_json
	uri = URI.parse(my_url)
	request = Net::HTTP::Put.new uri.path
	Rails.logger.info(' Request body: ')
	request.body = json_data
	Rails.logger.info(json_data)
	request.content_type = 'application/json'
	request.basic_auth 'mrjones', my_pass
	response = Net::HTTP.new(uri.host, uri.port).start { |http| http.request request }
	Rails.logger.info( 'response body:' )
	Rails.logger.info(response.body)
	@myresult = response.body
  end

  def seo_filters_update
	collection_filters = get_collection_filters
	collections = get_collections
	collection_filters.each do |el|
		temp = el['collection_id']
		puts temp
		puts collections
		puts collections[0]
		el['url']=collections[temp]+ '/' + el['permalink']
	end
	puts collection_filters
    # puts collections
  end

  private

  def get_collections
  	url = "http://" + subdomain + "/admin/collections.json"
	uri = URI.parse(url)
	request = Net::HTTP::Get.new uri.path
	request.basic_auth module_name, pass
	response = Net::HTTP.start(uri.host, uri.port) {|http| http.request(request)}
	collections = JSON.parse(response.body)
	collections2 ={}
	collections.each do |el|
		collections2[el['id']] = el['url']
	end
	collections2
  end 

  def get_collection_filters
  	url = "http://" + subdomain + "/admin/collection_filters.json"
	uri = URI.parse(url)
	request = Net::HTTP::Get.new uri.path
	request.basic_auth module_name, pass
	response = Net::HTTP.start(uri.host, uri.port) {|http| http.request(request)}
	collection_filters = JSON.parse(response.body)
	collection_filters2 = collection_filters.map do |filter|
		h = {}
		h['collection_id'] = filter['collection_id']
		h['permalink'] = filter['permalink']
		h['meta_keywords'] = filter['meta_keywords']
		h['property_id'] = filter['characteristis'][0]['property_id']
		h['title'] = filter['characteristis'][0]['title']
		h
	end
  end  

  def subdomain
  	@account.insales_subdomain
  end

  def pass
  	@account.password
  end

  def module_name
  	'mrjones'
  end

end
