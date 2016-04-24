require 'net/http'

class MainController < ApplicationController
  
  def index
  end

  def seo_filters_update
    days_upd_since = params[:days].to_i
    page_num = params[:page].to_i
    sfu = SeoFiltersUpdate.new(subdomain, pass, days_upd_since, page_num)
    sfu.account = @account
    sfu.get_products
    sfu.get_seofilters
    sfu.calc_products_description_links
    # sfu.calc_products_field_value_links
    @myresult = sfu.products_links
  end

  def put_one_product
  	sfu = ObjectSpace.each_object(SeoFiltersUpdate).to_a.last
  	if (sfu.nil?)
  		redirect_to '/'
  	else
  		@myresult = sfu.put_product_description_by_index(params[:arr_index])
      # @myresult = sfu.put_product_field_value_by_index(params[:arr_index])
  	end
  	@myresult
  end

  def put_one_product2
    product_id = params[:product_id]
    sfu = SeoFiltersUpdate.new(subdomain, pass)
    sfu.account = @account
    sfu.get_product(product_id)
    sfu.get_seofilters
    # sfu.calc_products_description_links
    sfu.calc_products_field_value_links
    # @myresult = sfu.put_product_description_by_index(0)
    @myresult = sfu.put_product_field_value_by_index(0)
    # render 'put_one_product'
    render 'put_one_product2'
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
    while (el_count == 250 && page_num <= 20) do
      Rails.logger.info("--------------- put_all_products2 Resque.enqueue page_num #{page_num} ---------------")
      Resque.enqueue(ResqueSeoFiltersUpdate, subdomain, pass, days_upd_since, page_num)      
      # Rails.logger.info("--------------- put_all_products2 page_num #{page_num} ---------------")
      # sfu = SeoFiltersUpdate.new(subdomain, pass, days_upd_since,page_num)
      # prod = sfu.get_products
      # el_count = sfu.products.count
      # sfu.get_seofilters
      # # sfu.calc_products_description_links
      # sfu.calc_products_field_value_links
      # res = sfu.put_all_products
      # products_updated += res
      page_num+=1
    end
    @myresult = 'Enqueued'
    @count_prod = 'In process'
  end

  private

  def subdomain
    @account.insales_subdomain
  end

  def pass
    @account.password
  end
    
end
