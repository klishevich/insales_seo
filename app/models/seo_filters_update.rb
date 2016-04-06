class SeoFiltersUpdate
	attr_accessor :account, :products, :seofilters, :product_links

	def get_products
		# updated_since = Time.now.strftime("%Y%m%d").to_s
		updated_since = (7.days.ago).strftime("%Y%m%d").to_s
		per_page='200'
		page_params="?per_page=#{per_page}&updated_since=#{updated_since}"
		url = "http://" + subdomain + "/admin/products.json"
		uri = URI.parse(url)
		request = Net::HTTP::Get.new (uri.path + page_params)
		request.basic_auth module_name, pass
		response = Net::HTTP.start(uri.host, uri.port) {|http| http.request(request)}
		@products = JSON.parse(response.body)
		temp_products = @products.map do |p|
			temp_hash = Hash.new
			temp_hash["id"] = p["id"]
			temp_hash["title"] = p["title"]
			temp_hash
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

	def calc_product_links
		product_links = Array.new
		@seofilters.each do |sf|
			pr = filter_products(sf["property_id"], sf["property_value"])
			pr.each do |product|
				temp_hash = Hash.new
				temp_hash["product_id"] = product["product_id"]
				temp_hash["product_title"] = product["product_title"]
				temp_hash["url"] = sf["url"]
				temp_hash["link_text"] = sf["link_text"]
				product_links.push(temp_hash)
			end
		end
		# sorted_product_links = product_links.sort_by { |hsh| hsh["product_id"] } 
		# prev_prod_id = -1
		# curr_prod_id = -1
		# sorted_product_links.each do |prodlink|
		# 	curr_prod_id = prodlink["product_id"]
		# 	if (curr_prod_id!=prev_prod_id)
		# 		temp_hash = Hash.new
		# 		temp_hash["product_id"]=curr_prod_id
		# 		temp_hash["product_links"]=[]
		# 		unique_product_links.push(temp_hash)
		# 	end
		# 	unique_product_links[curr_prod_id]
		# end
		# @product_links = product_links.sort_by { |hsh| hsh["product_id"] }  
		@product_links = product_links.group_by{|h| h["product_id"]}.values
		Rails.logger.info("------- 3) calc_product_links @product_links #{@product_links.count} -------")
		Rails.logger.info(@product_links)
	end

	def put_product_by_index(ar_ind)
		ar_index = ar_ind.to_i
		# puts "ar_index #{ar_index}" 
		# puts "@product_links[ar_index]"
		# puts @product_links[ar_index]["product_id"]
		product_id = @product_links[ar_index][0]["product_id"]
		# puts "product_id #{product_id}"
		product_a_link = ""
		@product_links[ar_index].each do |prod_link|
			product_url = prod_link["url"]
			product_link_text = prod_link["link_text"]
			product_a_link += "<div><a href=#{product_url}>#{product_link_text}</a></div>"
		end
		puts "product_a_link #{product_a_link}"
		my_subdomain = @account.insales_subdomain
		my_pass = @account.password
		my_url = "http://" + my_subdomain + "/admin/products/" + product_id.to_s + ".json"
		# Rails.logger.info( 'my_url:' )
		# Rails.logger.info(my_url)
		json_data = {
			"id" => product_id,
			"description" => product_a_link
			}.to_json
		uri = URI.parse(my_url)
		request = Net::HTTP::Put.new uri.path
		Rails.logger.info(' Request body: ')
		request.body = json_data
		Rails.logger.info(json_data)
		request.content_type = 'application/json'
		request.basic_auth 'mrjones', my_pass
		response = Net::HTTP.new(uri.host, uri.port).start { |http| http.request request }
		Rails.logger.info( 'response body:' )
		Rails.logger.info(response.body)
		res = JSON.parse(response.body)
		# puts res
		Rails.logger.info("------- 4) put_product_by_index -------")
		Rails.logger.info('request.body')
		Rails.logger.info(request.body)
		Rails.logger.info('response.body')
		Rails.logger.info(res)
		res
	end

	private
	# int, string
	def filter_products(property_id, property_value)
		temp=Set.new
		@products.each do |p|
			characteristics = p["characteristics"]
			characteristics.each do |c|
				if (c["property_id"] == property_id) && (c["title"] == property_value)
					temp_hash = Hash.new
					temp_hash["product_id"] = p["id"]
					temp_hash["product_title"] = p["title"]
					temp.add(temp_hash) 
				end
			end
		end
		temp.to_a
	end

	def get_collection_filters
		url = "http://" + subdomain + "/admin/collection_filters.json"
		uri = URI.parse(url)
		request = Net::HTTP::Get.new uri.path
		request.basic_auth module_name, pass
		response = Net::HTTP.start(uri.host, uri.port) {|http| http.request(request)}
		collection_filters = JSON.parse(response.body)
		Rails.logger.info("------- get_collection_filters collection_filters #{collection_filters.count} -------")
		Rails.logger.info(collection_filters)
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