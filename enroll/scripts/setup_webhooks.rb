require 'json'
require 'cgi'
require 'optparse'

require_relative '../app/helpers/api_oauth_request'

class TaskManager

	attr_accessor :twitter_api,
	              :webhook_url, #https://there.me/webhooks/twitter
	              :webhook_id, #Returned when setting up a Webhook with URL.
	              :webhook_configs  #An array of Webhook IDs. Currently numeric(e.g. 88888888888888), subject to change?
	
	def initialize(config_file=nil, url=nil)
		
		if config_file.nil?
			config = '../../config/config.yaml'
		else
			config = config_file
		end

		@twitter_api = ApiOauthRequest.new(config)
		@twitter_api.uri_path = '/1.1/account_activity'
		@twitter_api.get_api_access
		
		@webhook_configs = []
		
	end	
  
	def get_webhook_configs
		puts "Retrieving webhook configurations..."

		uri_path =  "#{@twitter_api.uri_path}/webhooks.json"

		response = @twitter_api.make_get_request(uri_path)

		results = JSON.parse(response)

		if results.count == 0
			puts "No existing configurations... "
		else
			results.each do |result|
				@webhook_configs << result
			end
		end

		@webhook_configs
	end

	def set_webhook_config(url)
		puts "Setting a webhook configuration..."

		uri_path = "#{@twitter_api.uri_path}/webhooks.json?url=#{url}"

		response = @twitter_api.make_post_request(uri_path,nil)
		results = JSON.parse(response)
		
		if results['errors'].nil?
			@webhook_id = results['id']
			@webhook_url = results['url']
			puts "Created webhook instance with webhook_id: #{@webhook_id} | pointing to #{@webhook_url}"
		else
			puts results['errors']
		end

		results
	end

	def delete_webhook_config(id)
		puts "Attempting to delete configuration for webhook id: #{id}."
		uri_path =  "#{@twitter_api.uri_path}/webhooks/#{id}.json"
		response = @twitter_api.make_delete_request(uri_path)

		if response == '204'
			puts "Webhook configuration for #{id} was successfully deleted."
		else
			puts response
		end

		response
	end

	def get_webhook_subscription(id)
		puts "Retrieving webhook subscriptions..."

		uri_path = "#{@twitter_api.uri_path}/webhooks/#{id}/subscriptions.json"

		response = @twitter_api.make_get_request(uri_path)

		if response == '204'
			puts "Webhook subscription exists for #{id}."
		else
			puts "Webhook subscription does not exist for #{id}."
		end
		
		response
	end

	# Sets a subscription for
	# https://dev.twitter.com/webhooks/reference/post/account_activity/webhooks/subscriptions
	def set_webhook_subscription(id)
		puts "Setting subscription for 'host' account for webhook id: #{id}"

		uri_path = "#{@twitter_api.uri_path}/webhooks/#{id}/subscriptions.json"
		response = @twitter_api.make_post_request(uri_path, nil)
		
		if response == '204'
			puts "Webhook subscription for #{id} was successfully added."
		else
			puts response
		end

    response
	end
	
	def delete_webhook_subscription(id)
		puts "Attempting to delete subscription for webhook: #{id}."
		uri_path =  "#{@twitter_api.uri_path}/webhooks/#{id}/subscriptions.json"
		response = @twitter_api.make_delete_request(uri_path)

		if response == '204'
			puts "Webhook subscription for #{id} was successfully deleted."
		else
			puts response
		end
		
		response
	end

	# https://dev.twitter.com/webhooks/reference/put/account_activity/webhooks
	# PUT https://api.twitter.com/1.1/account_activity/webhooks/:webhook_id.json
	def confirmCRC(id = nil)
		response = @twitter_api.make_put_request("#{@uri_path}/webhooks/#{@webhook_id}.json")

		results = JSON.parse(response)

		puts results
	end

end

#=======================================================================================================================
if __FILE__ == $0 #This script code is executed when running this file.

  #Supporting any command-line options? Handle here.
  #options: -config -id -url
	OptionParser.new do |o|

		#Passing in a config file.... Or you can set a bunch of parameters.
		o.on('-c CONFIG', '--config', 'Configuration file (including path) that provides account OAuth details.
                                       Config files include username, password, account name and stream label/name.') { |config| $config = config}
		o.on('-t TASK','--task', "Securing Webhooks Task to perform: trigger CRC ('crc'), set config ('set'), list configs ('list'), delete config ('delete'), subscribe app ('subscribe'), unsubscribe app ('unsubscribe'),get subscription ('subscription').") {|task| $task = task}
		o.on('-u URL','--url', "Webhooks 'consumer' URL, e.g. https://mydomain.com/webhooks/twitter.") {|url| $url = url}
		o.on('-i ID','--id', 'Webhook ID') {|id| $id = id}
				
		#Help screen.
		o.on( '-h', '--help', 'Display this screen.' ) do
			puts o
			exit
		end

		o.parse!
	end
	
	#Defaults?
	if $task.nil? then 
		$task = 'list'
	end
	
	if $config.nil? #Passed in config file needs to use a relative path...
		$config = File.join(File.dirname(__FILE__), '../config/config.yaml') #This is referenced by APIOAuthRequest class, so relative to its location.
	else
		$config = File.join(File.dirname(__FILE__), $config)
	
	end
	
	if $url.nil?
		$url = 'https://floodsocial.herokuapp.com/webhooks/twitter'
	end
	
	url = CGI::escape($url)

  task_manager = TaskManager.new($config)
	
	if $task == 'list'
		configs = task_manager.get_webhook_configs
		configs.each do |config|
			puts "Webhook ID #{config['id']} --> #{config['url']}}"
		end
	elsif $task == 'set'
		task_manager.set_webhook_config(url)
	elsif $task == 'delete'
		task_manager.delete_webhook_config($id)
	elsif $task == 'subscribe'
		task_manager.set_webhook_subscription($id)
	elsif $task == 'unsubscribe'
		task_manager.delete_webhook_subscription($id)
	elsif $task == 'subscription'
		task_manager.get_webhook_subscription($id)
	elsif $task == 'crc' #triggers a CRC for all configured unless a specific webhook ID is passed in.
		
		if $id.nil?
			#Get all configs
			result = task_manager.get_webhook_configs
			
			#extract IDs.
			ids = ''
			
			ids.each do |id|
				result = task_manager.confirm_crc(id)
				puts result
			end	
		else
			result = task_manager.confirm_crc($id)
			puts result
		end
	else
		puts "Unhandled task. Available tasks: 'list', 'crc', 'set', 'subscribe', 'delete'"
	end	
end
