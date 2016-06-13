class ResqueSeoFiltersUpdate
  @queue = :seo_pages_queue

  def self.perform(subdomain, pass, product_field_id_seo, days_upd_since, page_num)
    Logger.new('log/resque.log').info("--------- ResqueSeoFiltersUpdate start ---------")
    Logger.new('log/resque.log').info("subdomain #{subdomain}, days_upd_since #{days_upd_since}, page_num #{page_num}")
	sfu = SeoFiltersUpdate.new(subdomain, pass, product_field_id_seo, days_upd_since, page_num)
	sfu.get_products
	products_cnt = sfu.products.count
	# Logger.new('log/resque.log').info("products_cnt #{products_cnt}")
	products_to_update = -1
	if products_cnt > 0
		sfu.get_seofilters
		# sfu.calc_products_description_links
		sfu.calc_products_field_value_links
		products_to_update = sfu.products_links.count
		sfu.put_all_products
	end
    # Logger.new('log/resque.log').info("products_cnt #{products_cnt}, products_to_update #{products_to_update}")
    Logger.new('log/resque.log').info("--------- ResqueSeoFiltersUpdate finish ---------")
  end
end