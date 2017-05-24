require 'json'
require 'optparse'

require_relative '../app/helpers/api_oauth_request'
require_relative '../app/helpers/generate_direct_message_content'

class WelcomeMessageManager

	attr_accessor :twitter_api,
	              :message_generator
	
	def initialize(config_file)
		if config_file.nil?
			config = '../../config/config.yaml'
		else
			config = config_file
		end

		@twitter_api = ApiOauthRequest.new(config)
		@twitter_api.uri_path = '/1.1/direct_messages'
		@twitter_api.get_api_access
		
		@message_generator = GenerateDirectMessageContent.new
				
	end
	
	def set_default_welcome_message

		puts "Setting default Welcome Message..."

		uri_path = "#{@twitter_api.uri_path}/welcome_messages/new.json"

		welcome_message = @message_generator.generate_welcome_message_default

		response = @twitter_api.make_post_request(uri_path, welcome_message)
		results = JSON.parse(response)

		message_id = results['welcome_message']['id']

		set_rule = {}
		set_rule['welcome_message_rule'] = {}
		set_rule['welcome_message_rule']['welcome_message_id'] = message_id

		uri_path = "#{@twitter_api.uri_path}/welcome_messages/rules/new.json"

		response = @twitter_api.make_post_request(uri_path, set_rule.to_json)
		results = JSON.parse(response)

		rule_id = results['id']
		puts rule_id

	end
	
	def delete_default_welcome_message
		
		
	end
	
	def get_message_rules

		puts "Getting welcome message rules list."

		uri_path = "#{@twitter_api.uri_path}/welcome_messages/rules/list.json"
		response = @twitter_api.make_get_request(uri_path)

		results = JSON.parse(response)

		results
		
	end
	
	def delete_message_rule(id)

		puts "Deleting rule with id: #{id}."

		uri_path = "#{@twitter_api.uri_path}/welcome_messages/rules/destroy.json?id=#{id}"
		response = @twitter_api.make_get_request(uri_path)

		results = JSON.parse(response)

		results
		
	end

end


#=======================================================================================================================
if __FILE__ == $0 #This script code is executed when running this file.

	#Supporting any command-line options? Handle here.
	#options: -config -id -url
	OptionParser.new do |o|

		#Passing in a config file.... Or you can set a bunch of parameters.
		o.on('-c', '--config', 'Configuration file (including path) that provides account OAuth details. ') { |config| $config = config}
		o.on('-m', '--create', 'Create (make!) a default Welcome Message.') { |make| $make = make}
		o.on('-s', '--set', 'Set default Welcome Message.') { |set| $set = set}
		o.on('-d', '--delete', 'Delete default Welcome Message.') { |delete| $delete = delete}
		
		#Help screen.
		o.on( '-h', '--help', 'Display this screen.' ) do
			puts o
			exit
		end

		o.parse!
	end

	#Defaults?
	if $config.nil? #Passed in config file needs to use a relative path...
		$config = File.join(File.dirname(__FILE__), '../config/config.yaml') #This is referenced by APIOAuthRequest class, so relative to its location.
	else
		$config = File.join(File.dirname(__FILE__), $config)

	end

	message_manager = WelcomeMessageManager.new($config)
	
	if !$set.nil?
		message_manager.set_default_welcome_message
	end
	
	
	

end

