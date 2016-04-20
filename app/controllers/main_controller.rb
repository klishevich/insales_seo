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
    # sfu.calc_products_links2
    @myresult = sfu.products_links
  end

  def put_one_product
  	sfu = ObjectSpace.each_object(SeoFiltersUpdate).to_a.last
  	if (sfu.nil?)
  		redirect_to '/'
  	else
  		@myresult = sfu.put_product_by_index(params[:arr_index])
      # @myresult = sfu.put_product_by_index2(params[:arr_index])
  	end
  	@myresult
  end

  def put_one_product2
    product_id = params[:product_id]
    sfu = SeoFiltersUpdate.new
    sfu.account = @account
    sfu.get_product(product_id)
    sfu.get_seofilters
    sfu.calc_products_links
    # sfu.calc_products_links2
    @myresult = sfu.put_product_by_index(0)
    # @myresult = sfu.put_product_by_index2(0)
    render 'put_one_product'
    # render 'put_one_product2'
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
