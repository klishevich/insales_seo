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

 #  def put_product
 #  	product_id = params[:id]
 #  	product_title = params[:title]
 #  	my_subdomain = @account.insales_subdomain
 #  	my_pass = @account.password
 #  	my_url = "http://" + my_subdomain + "/admin/products/" + product_id + ".xml"
	# Rails.logger.info( 'my_url:' )
	# Rails.logger.info(my_url)
 #  	xml_data = %{<?xml version="1.0" encoding="UTF-8"?>
	# 	<product>
 #    		<id type="integer">} + product_id + %{</id>
 #    		<title>} + product_title + %{</title>
	# 	</product>}
	# uri = URI.parse(my_url)
	# request = Net::HTTP::Put.new uri.path
	# Rails.logger.info(' Request body: ')
	# request.body = xml_data
	# Rails.logger.info(xml_data)
	# request.content_type = 'text/xml'
	# request.basic_auth 'mrjones', my_pass
	# response = Net::HTTP.new(uri.host, uri.port).start { |http| http.request request }
	# Rails.logger.info( 'response body:' )
	# Rails.logger.info(response.body)
	# @myresult = response.body
 #  end

end
