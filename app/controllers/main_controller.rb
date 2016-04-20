require 'net/http'

class MainController < ApplicationController
  
  def index
  end

  def seo_filters_update
    days_upd_since = params[:days].to_i
    page_num = params[:page].to_i
    sfu = SeoFiltersUpdate.new(days_upd_since,page_num)
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
    days_upd_since = params[:days].to_i
    page_num = 1
    el_count = 250
    products_updated = []
    while (el_count > 0 && page_num < 40) do
      sfu = SeoFiltersUpdate.new(days_upd_since,page_num)
      sfu.account = @account
      sfu.get_products
      sfu.get_seofilters
      sfu.calc_products_links
      res = sfu.put_all_products
      products_updated += res
      page_num+=1
    end
    @myresult = products_updated
  end
end
