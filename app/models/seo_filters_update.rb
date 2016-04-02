class SeoFiltersUpdate
	attr_accessor :account, :products, :collection_urls

	def get_products
		url = "http://" + subdomain + "/admin/products.json"
		uri = URI.parse(url)
		request = Net::HTTP::Get.new uri.path
		request.basic_auth module_name, pass
		response = Net::HTTP.start(uri.host, uri.port) {|http| http.request(request)}
		@products = JSON.parse(response.body)  	
	end

	# int, string
	def filter_products(property_id, property_value)
		temp=Set.new
		# puts "property_id #{property_id}"
		# puts "property_value #{property_value}"
		# puts "temp #{temp}"
		@products.each do |p|
			# puts "product #{p["id"]}"
			characteristics = p["characteristics"]
			characteristics.each do |c|
				# puts "characteristics #{c["property_id"]} #{c["title"]}"
				if (c["property_id"] == property_id) && (c["title"] == property_value)
					puts "equal !!!!"
					temp.add(p["id"]) 
				end
			end
		end
		temp.to_a
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
		@collection_urls = collections2
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
			h['link_text'] = filter['meta_keywords']
			h['property_id'] = filter['characteristis'][0]['property_id']
			h['property_value'] = filter['characteristis'][0]['title']
			h
		end
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