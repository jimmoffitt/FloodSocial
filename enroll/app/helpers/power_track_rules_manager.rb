require 'json'

class APIBasicRequest
	require "net/https" #HTTP gem.
	require "uri"

	attr_accessor :url, :uri, :keys, :headers, :data

	def initialize(config_file)

		#Load configuration.
		
		@keys = {}
		
		if File.file?(config_file)
			puts 'Loading config file...'
			keys = YAML::load_file(config_file)
			@keys = keys['power_track']
		end
		
		if @keys.empty?
			puts "Pulling from ENV[]"
			if @keys['user_name'].nil? or @keys['user_name'] == ''
				@keys['user_name'] = ENV['GNIP_USER_NAME']
				@keys['password'] = ENV['GNIP_PASSWORD']
				@key['account_name'] = ENV['GNIP_ACCOUNT_NAME']
				@keys['label'] = ENV['GNIP_LABEL']
			end
		end
		
		@url = "https://gnip-api.twitter.com/rules/powertrack/accounts/#{@keys['account_name']}/publishers/twitter/#{@keys['label']}.json"
		puts "@url=#{@url}"

	end

	def POST_with_delete(data=nil)

		if not data.nil? #if request data passed in, use it.
			@data = data
		end

		uri = URI(@url)
		http = Net::HTTP.new(uri.host, uri.port)

		http.use_ssl = true
		request = Net::HTTP::Post.new(uri.path + "?_method=delete")
		request.body = @data
		request.basic_auth(@keys['user_name'], @keys['password'])

		begin
			response = http.request(request)
		rescue
			sleep 5
			response = http.request(request) #try again
		end

		return response

	end

	#Fundamental REST API methods:
	def POST(data=nil)

		if not data.nil? #if request data passed in, use it.
			@data = data
		end

		uri = URI(@url)
		http = Net::HTTP.new(uri.host, uri.port)

		http.use_ssl = true
		request = Net::HTTP::Post.new(uri.path)
		request.body = @data
		request.basic_auth(@keys['user_name'], @keys['password'])

		begin
			response = http.request(request)
		rescue
			sleep 5
			response = http.request(request) #try again
		end

		return response
	end

	def GET(params=nil)
		uri = URI(@url)

		#params are passed in as a hash.
		#Example: params["max"] = 100, params["since_date"] = 20130321000000
		if not params.nil?
			uri.query = URI.encode_www_form(params)
		end

		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = true
		request = Net::HTTP::Get.new(uri.request_uri)
		request.basic_auth(@keys['user_name'], @keys['password'])

		begin
			response = http.request(request)
		rescue
			sleep 5
			response = http.request(request) #try again
		end

		return response
	end

end

class PowerTrackRulesManager

	require 'json'
	require 'csv'

	attr_accessor :keys,
	              :source,
	              :locations,
	              :radius

	def initialize
		config = File.join(APP_ROOT, 'config', 'config.yaml')

		#Load config parameters.
		keys = YAML::load_file(config)
		@keys = keys['power_track']

		#Create HTTP RESTful object for making requests.
		@http = APIBasicRequest.new(config)

		#TODO - add feature to make point raduis distance customizable?
		@radius = 25
		#TODO - set @sources based on config.yaml specification.
		@sources = %w[USGS_TexasFlood USGS_TexasRain]

		begin
			@locations = CSV.read(File.join(APP_ROOT, 'data', 'placesOfInterest.csv'))
		rescue
			@locations = '/Users/jmoffitt/work/dm-api-ruby-client/data/placesOfInterest.csv'
		end

	end

	def get_rules
		response = @http.GET
		rules = JSON.parse(response.body)
		rules['rules']
	end

	#https://gnip-api.twitter.com/rules/powertrack/accounts/jim/publishers/twitter/floodsocial.json?_method=delete"
	def delete_rule(rule)
		request_json = set_rules_json(rule)
		response = @http.POST_with_delete(request_json)
	end

	def add_rule(json)
		response = @http.POST(json)
	end

	def set_rule_syntax(long, lat, sources, user_id)

		from_clauses = ''
		sources.each do |source|
			from_clauses = "from:#{source} OR #{from_clauses}"
		end
		#Remove Trailing 'OR'
		from_clauses = from_clauses[0..-5]
		from_clauses = "(#{from_clauses})"

		syntax = "point_radius:[#{long} #{lat} #{@radius}mi] #{from_clauses} -(\"#{user_id}\")"

	end

	def set_rules_json(syntax, tag=nil)

		rule = {}

		rule['value'] = syntax
		rule['tag'] = "#{tag}" if not tag.nil?

		rules = {}

		rules['rules'] = []
		rules['rules'] << rule

		rules.to_json

	end

	def get_coordinates(location_of_interest)

		coordinates = []

		@locations.each do |location|
			if location[0] == location_of_interest
				coordinates << location[1]
				coordinates << location[2]
				break
			end
		end

		coordinates
	end

	def add_rule_for_list_subscription(user_id, location_of_interest)

		#Based on list, look up coordinates
		coordinates = get_coordinates(location_of_interest)

		value = set_rule_syntax(coordinates[0], coordinates[1], @sources, user_id)
		#Build tag using user ID and location of interest
		tag = "#{user_id}|#{location_of_interest} "
		puts tag

		rule_json = set_rules_json(value, tag)

		add_rule(rule_json)

		coordinates #Return these for conformation

	end

	def add_rule_for_map_subscription(user_id, long, lat, location_of_interest)
		value = set_rule_syntax(long, lat, @sources, user_id)
		#Build tag using user ID and location of interest
		tag = "#{user_id}|#{location_of_interest} "
		rule_json = set_rules_json(value, tag)
		add_rule(rule_json)
	end

	def delete_subscription(user_id)
		puts "Deleting all rules for user #{user_id}."

		rules_deleted = 0

		rules = get_rules

		puts rules.count

		rules.each do |rule|
			if rule['tag'].include?(user_id.to_s)
				delete_rule(rule['value'])
				rules_deleted = rules_deleted + 1
			end
		end

		puts "Deleted #{rules_deleted} rules."

	end

	def get_area_name_from_tag(rule)

		name = rule['tag'].split('|')[1]
		puts name

		name
	end

	def get_subscriptions(user_id)

		rules = get_rules

		area_names = []
		
		if !rules.nil?
			rules.each do |rule|
				if rule['tag'].include?(user_id.to_s)
					#puts "HAVE MATCH"
					area_names << get_area_name_from_tag(rule)
				end
			end
		end

		#Reverse-engineer the Area Names, or divine map centroid.
		area_names
	end

end

if __FILE__ == $0 #This script code is executed when running this file.

	manager = PowerTrackRulesManager.new

	sources = []
	sources << 'USGS_TexasFlood'
	sources << 'USGS_TexasRain'
	sources << 'snowman'
	long = -87.0000
	lat = 45.0000
	user_id = 17200032

	#manager.add_subscription_for_list_selection(user_id,'Austin')
	#manager.add_subscription_for_coordinates(user_id,long, lat)

	#puts manager.get_rules

	user_id = "944480690"

	manager.delete_subscription(user_id)


end