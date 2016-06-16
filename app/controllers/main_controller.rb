require 'net/http'

class MainController < ApplicationController
  
  def index
    @rinfo = Resque.info
    @rqueues = Resque.queues
  end

  def seo_filters_update
    days_upd_since = params[:days].to_i
    page_num = params[:page].to_i
    sfu = SeoFiltersUpdate.new(subdomain, pass, product_field_id_seo, days_upd_since, page_num)
    sfu.account = @account
    sfu.get_products
    sfu.get_seofilters
    sfu.calc_products_field_value_links
    @myresult = sfu.products_links
  end

  # def put_one_product
  # 	sfu = ObjectSpace.each_object(SeoFiltersUpdate).to_a.last
  # 	if (sfu.nil?)
  # 		redirect_to '/'
  # 	else
  # 		@myresult = sfu.put_product_description_by_index(params[:arr_index])
  # 	end
  # 	@myresult
  # end

  def put_one_product2
    product_id = params[:product_id]
    sfu = SeoFiltersUpdate.new(subdomain, pass, product_field_id_seo)
    sfu.account = @account
    sfu.get_product(product_id)
    sfu.get_seofilters
    sfu.calc_products_field_value_links
    @myresult = sfu.put_product_field_value_by_index(0)
    render 'put_one_product2'
  end

  # def put_all_products
  #   sfu = ObjectSpace.each_object(SeoFiltersUpdate).to_a.last
  #   if (sfu.nil?)
  #     redirect_to '/'
  #   else
  #     @myresult = sfu.put_all_products
  #   end
  #   @myresult
  # end

  def put_all_products2
    days_upd_since = params[:days].to_i
    page_num = 1
    el_count = 250
    # products_updated = []
    while (el_count == 250 && page_num <= @account.max_page_num) do
      Rails.logger.info("--------------- put_all_products2 Resque.enqueue page_num #{page_num} ---------------")
      Resque.enqueue(ResqueSeoFiltersUpdate, subdomain, pass, product_field_id_seo, days_upd_since, page_num)
      page_num+=1
    end
    redirect_to '/put_all_products_result'
  end

  def put_all_products_result
  end

  private

  def subdomain
    @account.insales_subdomain
  end

  def pass
    @account.password
  end

  def product_field_id_seo
    @account.account_info.seo_field_identifier
  end
    
end
