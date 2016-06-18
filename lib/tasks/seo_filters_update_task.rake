desc 'Enqueue SEO filters update'
task seo_filters_update: :environment do
	Logger.new('log/resque.log').info("------------ START CRON TASK seo_filters_update ------------")
	Account.all.each do |acc|
		if (acc.allow_work? && acc.auto_update? && acc.not_updated_today?)
		    page_num = 1
		    el_count = 250
		    is_last_page = false
		    while (el_count == 250 && page_num <= acc.max_page_num) do
		    	is_last_page = true if page_num == acc.max_page_num
		    	Resque.enqueue(ResqueSeoFiltersUpdate, acc.insales_subdomain, acc.password, 
		    		acc.account_info.seo_field_identifier, acc.account_info.day_to_update, page_num, is_last_page)
		    	page_num+=1
		    end
		end
	end
end