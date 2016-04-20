class SeoFiltersUpdate
	attr_accessor :account, :products, :seofilters, :products_links, :page_num, :days_upd_since
	
	def initialize(days_upd_since=14, page_num=1)
	   @products = Array.new
	   @page_num = page_num
	   @days_upd_since = days_upd_since
	end

	def get_products
		Rails.logger.info("------- 1) start get_products -------")
		per_page=250
		page=@page_num
		url = "http://" + subdomain + "/admin/products.json"
		uri = URI.parse(url)
		# el_count = 250
		updated_since = (@days_upd_since.days.ago).strftime("%Y%m%d").to_s
		# while (el_count > 0 && page < 10) do
		page_params="?per_page=#{per_page.to_s}&page=#{page.to_s}&updated_since=#{updated_since}"
		Rails.logger.info("page_params #{page_params}")
		request = Net::HTTP::Get.new (uri.path + page_params)
		request.basic_auth module_name, pass
		response = Net::HTTP.start(uri.host, uri.port) {|http| http.request(request)}
		parse_products = JSON.parse(response.body)
		@products = parse_products
		# parse_products.each {|i| @products << i }
		# page+=1
		el_count = parse_products.count
		Rails.logger.info("@products.count #{@products.count}")
		# end
		Rails.logger.info("------- 1) finish get_products @products.count #{@products.count} -------")
		# Rails.logger.info(temp_products)
	end

	def get_product(id)
		Rails.logger.info("------- 1) start get_product -------")
		url = "http://" + subdomain + "/admin/products/" + id.to_s + ".json"
		Rails.logger.info("url #{url}")
		uri = URI.parse(url)
		request = Net::HTTP::Get.new (uri.path)
		request.basic_auth module_name, pass
		response = Net::HTTP.start(uri.host, uri.port) {|http| http.request(request)}
		parse_product = JSON.parse(response.body)
		Rails.logger.info("parse_product #{parse_product}")
		@products << parse_product
		Rails.logger.info(parse_product.to_json)
		Rails.logger.info("------- 1) finish get_product -------")
	end

	def get_seofilters
		Rails.logger.info("------- 2) start get_seofilters -------")
		collection_filters = get_collection_filters
		collections = get_collections
		collection_filters.each do |el|
			temp = el['collection_id']
			el['url']=collections[temp]+ '/' + el['permalink']
		end
		@seofilters = collection_filters
		Rails.logger.info("------- 2) finish get_seofilters @seofilters.count #{@seofilters.count} -------")
		# Rails.logger.info(@seofilters)
	end

	def calc_products_links
		Rails.logger.info("------- 3) start calc_products_links -------")
		products_links = Array.new
		@products.each do |product|
			product_desc = product["description"]
			product_desc ||= ""
			plinks = calc_product_links(product)
			if (product_desc != plinks)
				temp_hash = Hash.new
				temp_hash["product_id"] = product["id"]
				temp_hash["product_title"] = product["title"]
				temp_hash["product_links"] = plinks
				temp_hash["need_update"] = true
				products_links.push(temp_hash)
			end	
		end
		@products_links = products_links
		Rails.logger.info("------- 3) finish calc_products_links @products_links.count #{@products_links.count} -------")
		# Rails.logger.info(@products_links)
	end

	def calc_products_links2
		Rails.logger.info("------- 3) start calc_products_links2 -------")
		products_links = Array.new
		@products.each do |product|
			#hardcode seo product_field_id = 31206
			product_seo = product["product_field_values"].select {|pfv| pfv["product_field_id"] == 31206 }.first
			product_seo ||= ""
			plinks = calc_product_links2(product)
			if (product_seo != plinks)
				temp_hash = Hash.new
				temp_hash["product_id"] = product["id"]
				temp_hash["product_title"] = product["title"]
				temp_hash["product_links"] = plinks
				temp_hash["need_update"] = true
				products_links.push(temp_hash)
			end	
		end
		@products_links = products_links
		Rails.logger.info("------- 3) finish calc_products_links2 @products_links.count #{@products_links.count} -------")
		# Rails.logger.info(@products_links)
	end

	def put_product_by_index(ar_ind)
		ar_index = ar_ind.to_i
		product_id = @products_links[ar_index]["product_id"]
		product_links = @products_links[ar_index]["product_links"]
		my_subdomain = @account.insales_subdomain
		my_pass = @account.password
		my_url = "http://" + my_subdomain + "/admin/products/" + product_id.to_s + ".json"
		json_data = {
			"id" => product_id,
			"description" => product_links
			}.to_json
		uri = URI.parse(my_url)
		request = Net::HTTP::Put.new uri.path
		request.body = json_data
		request.content_type = 'application/json'
		request.basic_auth 'mrjones', my_pass
		response = Net::HTTP.new(uri.host, uri.port).start { |http| http.request request }
		res = JSON.parse(response.body)
		Rails.logger.info("------- 4) put_product_by_index -------")
		Rails.logger.info('request.body')
		Rails.logger.info(request.body)
		res
	end

	def put_product_by_index2(ar_ind)
		ar_index = ar_ind.to_i
		product_id = @products_links[ar_index]["product_id"]
		product_links = @products_links[ar_index]["product_links"]
		my_subdomain = @account.insales_subdomain
		my_pass = @account.password
		my_url = "http://" + my_subdomain + "/admin/products/" + product_id.to_s + ".json"
		json_data = {
			"id" => product_id,
			"product_field_values" => [
				{
					"id" => 32184773,
					"product_field_id" => 31206,
					"value" => product_links 
				}
			]
			}.to_json
		uri = URI.parse(my_url)
		request = Net::HTTP::Put.new uri.path
		request.body = json_data
		request.content_type = 'application/json'
		request.basic_auth 'mrjones', my_pass
		response = Net::HTTP.new(uri.host, uri.port).start { |http| http.request request }
		res = JSON.parse(response.body)
		Rails.logger.info("------- 4) put_product_by_index2 -------")
		Rails.logger.info('request.body')
		Rails.logger.info(request.body)
		Rails.logger.info('response.body')
		Rails.logger.info(response.body)
		return res
	end

	def put_all_products
		updated_products = Array.new
		@products_links.each_with_index do |product, index|
			if product["need_update"] == true
				temp_hash = Hash.new
				temp_hash["index"] = index
				temp_hash["product_id"] = product["product_id"]
				temp_hash["product_title"] = product["product_title"]
				temp_hash["product_links"] = product["product_links"]
				updated_products.push(temp_hash)
				Rails.logger.info("-------  put_all_products index #{index}, product_id #{product["product_id"]}, product_title #{product["product_title"]}-------")
				put_product_by_index(index)
			end
		end
		return updated_products
	end

	private

	def calc_product_links(product)
		product_a_link = ""
		@seofilters.each do |sf|
			collection_id = sf["collection_id"]
			property_id = sf["property_id"]
			property_value = sf["property_value"]
			if (product["collections_ids"].include? collection_id) && 
				(product["characteristics"].select {|ch| ch["property_id"] == property_id && ch["title"] == property_value}.count > 0)
				product_url = sf["url"]
				product_link_text = sf["link_text"]
				product_a_link += "<span><a href=#{product_url}>#{product_link_text}</a>&nbsp;&nbsp;&nbsp;&nbsp;</span>"
			end
		end
		# Rails.logger.info("------- calc_product_links product_a_link #{product["title"]} #{product["id"]} #{product_a_link} -------")
		# Rails.logger.info(@product_links)
		return product_a_link
	end

	def calc_product_links2(product)
		product_a_link = ""
		@seofilters.each do |sf|
			collection_id = sf["collection_id"]
			property_id = sf["property_id"]
			property_value = sf["property_value"]
			if (product["collections_ids"].include? collection_id) && 
				(product["characteristics"].select {|ch| ch["property_id"] == property_id && ch["title"] == property_value}.count > 0)
				product_url = sf["url"]
				product_link_text = sf["link_text"]
				product_a_link += "<span><a href=#{product_url}>#{product_link_text}</a>&nbsp;&nbsp;&nbsp;&nbsp;</span>"
			end
		end
		# Rails.logger.info("------- calc_product_links product_a_link #{product["title"]} #{product["id"]} #{product_a_link} -------")
		# Rails.logger.info(@product_links)
		return product_a_link
	end

	def get_collection_filters
		url = "http://" + subdomain + "/admin/collection_filters.json"
		uri = URI.parse(url)
		request = Net::HTTP::Get.new uri.path
		request.basic_auth module_name, pass
		response = Net::HTTP.start(uri.host, uri.port) {|http| http.request(request)}
		collection_filters = JSON.parse(response.body)
		collection_filters2 = collection_filters.map do |filter|
			h = {}
			h['collection_id'] = filter['collection_id']
			h['permalink'] = filter['permalink']
			h['link_text'] = filter['meta_keywords'] ? filter['meta_keywords'] : filter['title']
			h['property_id'] = filter['characteristis'].count > 0 ? filter['characteristis'][0]['property_id'] : -1
			h['property_value'] = filter['characteristis'].count > 0 ? filter['characteristis'][0]['title'] : -1
			h
		end
		Rails.logger.info("------- get_collection_filters collection_filters2 #{collection_filters2.count} -------")
		Rails.logger.info(collection_filters2)
		collection_filters2
	end

	def get_collections
		url = "http://" + subdomain + "/admin/collections.json"
		uri = URI.parse(url)
		request = Net::HTTP::Get.new uri.path
		request.basic_auth module_name, pass
		response = Net::HTTP.start(uri.host, uri.port) {|http| http.request(request)}
		collections = JSON.parse(response.body)
		collections2 ={}
		collections.each do |el|
			collections2[el['id']] = el['url']
		end
		Rails.logger.info("------- get_collections collections2 #{collections2.count} -------")
		Rails.logger.info(collections2)
		collections2
	end  

	def subdomain
		@account.insales_subdomain
	end

	def pass
		@account.password
	end

	def module_name
		'mrjones'
	end

end