require 'yaml'
require 'json'
require 'oauth'

class ApiOauthRequest

	HEADERS = {"content-type" => "application/json"} #Suggested set? Any?

	attr_accessor :keys,
	              :twitter_api,
	              :base_url, #Default: 'https://api.twitter.com/'
	              :uri_path #No default.

	def initialize(config_file=nil)
		@base_url = 'https://api.twitter.com/'
		@uri_path = '' #'/1.1/direct_messages' or '/1.1/account_activity'

		if config_file.nil?
			config = '../../config/config.yaml'
		else
			config = config_file
		end
		
		#Get Twitter App keys and tokens. Read from 'config.yaml' if provided, or if running on Heroku, pull from the 
		#'Config Variables' via the ENV{} hash/
		@keys = {}

		if File.file?(config)
			keys = YAML::load_file(config)
			@keys = keys['dm_api']
		end
			
		if @keys['consumer_key'].nil? or @key['consumer_key'] == ''
			puts "Pulling from ENV[]"
			@keys['consumer_key'] = ENV['CONSUMER_KEY']
			@keys['consumer_secret'] = ENV['CONSUMER_SECRET']
			@keys['access_token'] = ENV['ACCESS_TOKEN']
			@keys['access_token_secret'] = ENV['ACCESS_TOKEN_SECRET']
		end
	end

	def get_api_access
		consumer = OAuth::Consumer.new(@keys['consumer_key'], @keys['consumer_secret'], {:site => @base_url})
		token = {:oauth_token => @keys['access_token'],
		         :oauth_token_secret => @keys['access_token_secret']
		}

		@twitter_api = OAuth::AccessToken.from_hash(consumer, token)

	end

	def make_post_request(uri_path, request)
		get_api_access if @twitter_api.nil? #token timeout?

		response = @twitter_api.post(uri_path, request, HEADERS)

		if response.code.to_i >= 300
			puts "error: #{response}"
		end
		
		puts "response.code: #{response.code}"
		puts "response.body: #{response.body}"

		if response.body.nil? #Some successful API calls have nil response bodies, but have 2## response codes.
			 return response.code #Examples include 'set subscription', 'get subscription', and 'delete subscription'
		else
			return response.body
		end

	end

	def make_get_request(uri_path)
		get_api_access if @twitter_api.nil? #token timeout?

		response = @twitter_api.get(uri_path, HEADERS)
		
		if response.code.to_i >= 300
			puts "error: #{response}"
		end

		if response.body.nil? #Some successful API calls have nil response bodies, but have 2## response codes.
			return response.code #Examples include 'set subscription', 'get subscription', and 'delete subscription'
		else
			return response.body
		end
	end

	def make_delete_request(uri_path)
		get_api_access if @twitter_api.nil? #token timeout?

		response = @twitter_api.delete(uri_path, HEADERS)

		if response.code.to_i >= 300
			puts "error: #{response}"
		end

		if response.body.nil? #Some successful API calls have nil response bodies, but have 2## response codes.
			return response.code #Examples include 'set subscription', 'get subscription', and 'delete subscription'
		else
			return response.body
		end
	end

	def make_put_request(uri_path)

		get_api_access if @twitter_api.nil? #token timeout?

		response = @twitter_api.put(uri_path, '', {"content-type" => "application/json"})

		if response.code.to_i == 429
			puts "#{response.message}  - Rate limited..."
		end

		if response.code.to_i >= 300
			puts "error: #{response}"
		end

		if response.body.nil? #Some successful API calls have nil response bodies, but have 2## response codes.
			return response.code #Examples include 'set subscription', 'get subscription', and 'delete subscription'
		else
			return response.body
		end

	end

end