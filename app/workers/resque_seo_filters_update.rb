class ResqueSeoFiltersUpdate
  @queue = :seo_pages_queue

  def self.perform(subdomain, pass, product_field_id_seo, days_upd_since, page_num, is_last_page = false)
    Logger.new('log/resque.log').info("--------- ResqueSeoFiltersUpdate start ---------")
    Logger.new('log/resque.log').info("subdomain #{subdomain}, days_upd_since #{days_upd_since}, page_num #{page_num}")
	sfu = SeoFiltersUpdate.new(subdomain, pass, product_field_id_seo, days_upd_since, page_num )
	sfu.get_products
	products_cnt = sfu.products.count
	products_to_update = -1
	if products_cnt > 0
		sfu.get_seofilters
		sfu.calc_products_field_value_links
		products_to_update = sfu.products_links.count
		sfu.put_all_products
	end
    # Logger.new('log/resque.log').info("products_cnt #{products_cnt}, products_to_update #{products_to_update}")
    if is_last_page 
    	ac = Account.where(insales_subdomain: subdomain).first
    	now_date = Time.now
    	ac.account_info.last_seo_update = now_date
    	ac.account_info.save
    	Logger.new('log/resque.log').info("5) last page updated #{now_date}")
    end
    Logger.new('log/resque.log').info("--------- ResqueSeoFiltersUpdate finish ---------")
  end
end