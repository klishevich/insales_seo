require 'net/http'

class MainController < ApplicationController
  
  def index
  end

  def seo_filters_update
    sfu = SeoFiltersUpdate.new
    sfu.account = @account
    sfu.get_products
    sfu.get_seofilters
    sfu.calc_products_links
    # puts sfu.products.first["title"]
    # puts sfu.filter_products(1482648,'1')
    @myresult = sfu.products_links
  end

  def put_one_product
  	# puts ObjectSpace.each_object(SeoFiltersUpdate).to_a
    # Rails.logger.info("!!!! arr_index")
    # Rails.logger.info(params[:arr_index])
  	sfu = ObjectSpace.each_object(SeoFiltersUpdate).to_a.last
  	# Rails.logger.info("!!!! found SeoFiltersUpdate")
  	# Rails.logger.info("sfu.product_links")
  	if (sfu.nil?)
  		redirect_to '/'
  	else
  		@myresult = sfu.put_product_by_index(params[:arr_index])
  	end
  	@myresult
  end

  def put_all_products
    sfu = ObjectSpace.each_object(SeoFiltersUpdate).to_a.last
    if (sfu.nil?)
      redirect_to '/'
    else
      @myresult = sfu.put_all_products
    end
    @myresult
  end

  def put_all_products2
    sfu = SeoFiltersUpdate.new
    sfu.account = @account
    sfu.get_products
    sfu.get_seofilters
    sfu.calc_products_links
    @myresult = sfu.put_all_products
  end
end
