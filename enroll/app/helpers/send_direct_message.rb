require 'json'
require_relative 'request_manager'
require_relative 'generate_direct_message_content'

class SendDirectMessage

   attr_accessor :dm, 
				 :content,
				 :sender,
				 :location_list #This class knows the configurable location list. 

   def initialize

	  #@dm = ApiRequest.new('../../config/accounts_private.yaml') #this context does not work within Sinatra app...?
	  @dm = RequestManager.new(File.join(APP_ROOT, 'config', 'config_private.yaml'))
	  @dm.uri_path = '/1.1/direct_messages'
	  @dm.get_api_access
	  
	  @content = GenerateDirectMessageContent.new

	  locations = CSV.read(File.join(APP_ROOT, 'data', 'placesOfInterest.csv'))

	  @location_list = []
	  
	  locations.each do |location|
		 @location_list << location
	  end
   end
   
   
   #TODO: this method is NOT currently used by 'set-up' webhook scripts... E.g. default welcome message content is not managed here.
   #New users will be served this.
   #https://dev.twitter.com/rest/reference/post/direct_messages/welcome_messages/new
  
   #Send a DM back to user.
   #https://dev.twitter.com/rest/reference/post/direct_messages/events/new
   def send_direct_message(message)
	  puts "Sending Direct Message"
	  
	  #puts "Sending #{message}"

	  uri_path = "#{@dm.uri_path}/events/new.json"
	  response = @dm.make_post_request(uri_path, message)

	  results = JSON.parse(response)

	  results

   end
   
   def get_name_from_coordinates(subscriptions)
	  
	  translations = []
	  
	  subscriptions.each do |subscription|
		 #puts "Subscription: #{subscription}"
		 @location_list.each do |location|
		    if subscription.include?(location[1]) and subscription.include?(location[2])
			   puts "GOT A LOT TO DO with #{subscription}!!!! Need to translate to #{location[0]}"
  			   translations << location[0]
			else 
			   translations << subscription
			end
		 end
	  end
	  
	  puts "translations count: #{translations.count}"
	  
	  translations
	  
   end
   
   def send_welcome_message(user_id)
	  puts "(Re)send welcome message"
	  dm_content = @content.generate_welcome_message(user_id)
	  send_direct_message(dm_content)
   end
   
   def send_select_location_method_dm(user_id)
	  puts "(Re)send welcome message"
	  
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
	  puts "Sending current areas of interest!"
      subscriptions = get_name_from_coordinates(subscriptions)
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