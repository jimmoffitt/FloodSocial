require 'json'
require 'csv'
require_relative 'api_oauth_request'
require_relative 'generate_direct_message_content'

class SendDirectMessage

	attr_accessor :dm,
	              :content,
	              :sender,
	              :location_list #This class knows the configurable location list.

	def initialize

		#@dm = ApiRequest.new('../../config/accounts_private.yaml') #this context does not work within Sinatra app...?

		begin
			@dm = ApiOauthRequest.new(File.join(APP_ROOT, 'config', 'config.yaml'))
		rescue #Running outside of Sinatra?
			@dm = ApiOauthRequest.new('../../config/config.yaml')
		end

		@dm.uri_path = '/1.1/direct_messages'
		@dm.get_api_access

		@content = GenerateDirectMessageContent.new
		
		#puts "In SEND: APP_ROOT: #{APP_ROOT}"

		begin
			locations = CSV.read(File.join(APP_ROOT, 'data', 'placesOfInterest.csv'))
		rescue #Running outside of Sinatra?
			locations = CSV.read('../../data/placesOfInterest.csv')
		end

		@location_list = []

		locations.each do |location|
			@location_list << location[0] #Load just the location name.
		end
	end


	#TODO: this method is NOT currently used by 'set-up' webhook scripts...
	#New users will be served this.
	#https://dev.twitter.com/rest/reference/post/direct_messages/welcome_messages/new

	#Send a DM back to user.
	#https://dev.twitter.com/rest/reference/post/direct_messages/events/new
	def send_direct_message(message)
		
		uri_path = "#{@dm.uri_path}/events/new.json"
		response = @dm.make_post_request(uri_path, message)
  	puts "Attempted to send #{message} to #{uri_path}/events/new.json"
	
		#Currently, not returning anything... Errors reported in POST request code.
		#results = JSON.parse(response)
		#results 

	end

	def send_welcome_message(user_id)
		puts "(Re)send welcome message"
		dm_content = @content.generate_welcome_message(user_id)
		send_direct_message(dm_content)
	end

	def send_map(user_id)
		puts "Sending user map DM!"
		dm_content = @content.generate_location_map(user_id)
		send_direct_message(dm_content)
	end

	def send_location_list(user_id)
		puts "Sending user location list DM!"
		dm_content = @content.generate_location_list(user_id, @location_list)
		send_direct_message(dm_content)
	end

	def send_subscription_list(user_id, subscriptions)
		puts "Have filtered list with #{subscriptions.count} subs. Sending current areas of interest!"
		dm_content = @content.generate_subscription_list(user_id, subscriptions)
		send_direct_message(dm_content)
	end

	def send_system_info(user_id)
		puts "Sending system info."
		dm_content = @content.generate_system_info(user_id)
		send_direct_message(dm_content)
	end

	def send_confirmation(user_id, area_of_interest)
		puts "Sending user subscribe confirmation."
		dm_content = @content.generate_confirmation(user_id, area_of_interest)
		send_direct_message(dm_content)
	end

	def send_unsubscribe(user_id)
		puts "Sending user unsubscribe confirmation"
		dm_content = @content.generate_unsubscribe(user_id)
		send_direct_message(dm_content)
	end

end

if __FILE__ == $0 #This script code is executed when running this file.

	sender = SendDirectMessage.new
	sender.send_location_list(944480690)

	sender.send_map(944480690)

end