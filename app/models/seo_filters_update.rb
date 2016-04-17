class SeoFiltersUpdate
	attr_accessor :account, :products, :seofilters, :products_links

	def get_products
		@products = Array.new
		per_page=250
		page=1
		url = "http://" + subdomain + "/admin/products.json"
		uri = URI.parse(url)
		el_count = 250
		updated_since = (30.days.ago).strftime("%Y%m%d").to_s
		while (el_count > 0 && page < 20) do
			page_params="?per_page=#{per_page.to_s}&page=#{page.to_s}&updated_since=#{updated_since}"
			request = Net::HTTP::Get.new (uri.path + page_params)
			request.basic_auth module_name, pass
			response = Net::HTTP.start(uri.host, uri.port) {|http| http.request(request)}
			parse_products = JSON.parse(response.body)
			@products += parse_products
			page+=1
			el_count = parse_products.count
			Rails.logger.info("------- get_products while -------")
			# Rails.logger.info("parse_products #{parse_products}")
			Rails.logger.info("@products.count #{@products.count}")
			Rails.logger.info("page_params #{page_params}")
		end
		# updated_since = Time.now.strftime("%Y%m%d").to_s
		# updated_since = (30.days.ago).strftime("%Y%m%d").to_s
		# page_params="?per_page=#{per_page}&updated_since=#{updated_since}"
		temp_products = @products.map do |p|
			temp_hash = Hash.new
			temp_hash["id"] = p["id"]
			temp_hash["title"] = p["title"]
			# temp_hash["description"] = p["description"]
			temp_hash["collections_ids"] = p["collections_ids"]
			return temp_hash
		end
		Rails.logger.info("------- 1) get_products @products count #{@products.count} -------")
		Rails.logger.info(temp_products)
	end

	def get_seofilters
		collection_filters = get_collection_filters
		collections = get_collections
		collection_filters.each do |el|
			temp = el['collection_id']
			el['url']=collections[temp]+ '/' + el['permalink']
		end
		@seofilters = collection_filters
		Rails.logger.info("------- 2) get_seofilters @seofilters #{@seofilters.count} -------")
		Rails.logger.info(@seofilters)
	end

	def calc_products_links
		products_links = Array.new
		@products.each do |product|
			product_desc = product["description"]
			product_desc ||= ""
			plinks = calc_product_links(product)
			temp_hash = Hash.new
			temp_hash["product_id"] = product["id"]
			temp_hash["product_title"] = product["title"]
			temp_hash["product_links"] = plinks
			if (product_desc != plinks)
				temp_hash["need_update"] = true
				products_links.push(temp_hash)
			else
				temp_hash["need_update"] = false
			end	
		end
		@products_links = products_links
		Rails.logger.info("------- 3) calc_products_links @products_links #{@products_links.count} -------")
		Rails.logger.info(@products_links)
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
		Rails.logger.info("------- calc_product_links product_a_link #{product["title"]} #{product["id"]} #{product_a_link} -------")
		Rails.logger.info(@product_links)
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