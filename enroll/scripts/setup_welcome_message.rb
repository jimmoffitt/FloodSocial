require 'json'

require_relative '../app/helpers/api_oauth_request'
require_relative '../app/helpers/generate_direct_message_content'

class WelcomeManagerManager

	attr_accessor :twitter_api
	
	def initialize
		if config_file.nil?
			config = '../../config/config.yaml'
		else
			config = config_file
		end

		@twitter_api = ApiOauthRequest.new(config)
		@twitter_api.uri_path = '/1.1/direct_messages'
		@twitter_api.get_api_access
	end
	
	def create_welcome_message
		
	end
	
	def set_default_welcome_message
		
		
	end
	
	def delete_default_welcome_message
		
		
	end
	
	

end


#=======================================================================================================================
if __FILE__ == $0 #This script code is executed when running this file.

	#Supporting any command-line options? Handle here.
	#options: -config -id -url
	OptionParser.new do |o|

		#Passing in a config file.... Or you can set a bunch of parameters.
		o.on('-c CONFIG', '--config', 'Configuration file (including path) that provides account OAuth details. ') { |config| $config = config}
		o.on('-m MAKE', '--create', 'Create (make!) a default Welcome Message.') { |make| $make = make}
		o.on('-s SET', '--set', 'Set default Welcome Message.') { |set| $set = set}
		o.on('-d DELETE', '--delete', 'Delete default Welcome Message.') { |delete| $delete = delete}
		
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

end

