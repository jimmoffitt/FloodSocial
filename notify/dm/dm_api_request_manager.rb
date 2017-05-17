require 'yaml'
require 'json'
require 'oauth'

class ApiOauthRequest

   HEADERS = {"content-type" => "application/json"} #Suggested set? Any?

   attr_accessor :keys,
				 :twitter_api,
				 :base_url, #Default: 'https://api.twitter.com/'
				 :uri_path #No default.

   def initialize(config_file)
	  @base_url = 'https://api.twitter.com/'
	  @uri_path = ''  #'/1.1/direct_messages' or '/1.1/account_activity'

	  if config_file.nil?
		 config = '../config/config.yaml'
	  else
		 config = config_file
	  end

	  keys = YAML::load_file(config)
	  @keys = keys['send_dm']
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

	  result = @twitter_api.post(uri_path, request, HEADERS)

	  if result.code.to_i >= 300
		 puts "error: #{result}"
	  end

	  result.body
   end

   def make_get_request(uri_path)
	  get_api_access if @twitter_api.nil? #token timeout?

	  result = @twitter_api.get(uri_path, HEADERS)

	  if result.code.to_i >= 300
		 puts "error: #{result}"
	  end

	  result.body
   end

   def make_delete_request(uri_path)
	  get_api_access if @twitter_api.nil? #token timeout?

	  response = @twitter_api.delete(uri_path, HEADERS)

	  if response.code.to_i >= 300
		 puts "error: #{response}"
	  end

	  response.body
   end

   def make_put_request(uri_path)

	  get_api_access if @twitter_api.nil? #token timeout?

	  response = @twitter_api.put(uri_path,'', {"content-type" => "application/json"})


	  if response.code.to_i == 429
		 puts "#{response.message} Rate limited... Handle!"
	  end


	  if response.code.to_i >= 300
		 puts "error: #{response}"
	  end

	  response.body

   end

end