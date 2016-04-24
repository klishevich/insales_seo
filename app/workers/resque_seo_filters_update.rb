class ResqueSeoFiltersUpdate
  @queue = :seo_pages_queue

  def self.perform(account_id,days_upd_since,page_num)
    Rails.logger.info("--------------- ResqueSeoFiltersUpdate page_num #{page_num} ---------------")
	sfu = SeoFiltersUpdate.new(days_upd_since,page_num)
	sfu.account = @account
	sfu.set_account_by_id(account_id)
	sfu.get_products
	sfu.get_seofilters
	# sfu.calc_products_description_links
	sfu.calc_products_field_value_links
	sfu.put_all_products
  end
end