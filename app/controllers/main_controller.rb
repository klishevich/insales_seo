require 'net/http'

class MainController < ApplicationController
  def index
  end

  def get_products
  	my_subdomain = @account.insales_subdomain
  	my_pass = @account.password
  	my_url = "http://" + my_subdomain + "/admin/products.xml"
	Rails.logger.info( 'my_url:' )
	Rails.logger.info(my_url)
  	# xml_data = %{<?xml version="1.0" encoding="UTF-8"?>}
	uri = URI.parse(my_url)
	request = Net::HTTP::Get.new uri.path
	# request.body = xml_data
	# request.content_type = 'text/xml'
	# request.basic_auth 'mrjones', my_pass
	response = Net::HTTP.start(uri.host, uri.port) {|http| http.request(request)}
	Rails.logger.info( 'response body:' )
	Rails.logger.info(response.body)
	@myresult = response.body
  end
end
