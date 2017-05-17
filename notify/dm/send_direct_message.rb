require 'json'
require_relative 'dm_api_request_manager'

class SendDirectMessage

   attr_accessor :dm

   def initialize
	  @dm = ApiOauthRequest.new('config_private.yaml')
	  #@dm = ApiOauthRequest.new(File.join(APP_ROOT, 'config', 'config_private.yaml'))
	  @dm.uri_path = '/1.1/direct_messages'
	  @dm.get_api_access
   end
  
   #https://dev.twitter.com/rest/reference/post/direct_messages/events/new
   def send_direct_message(message)
	  puts "Sending Direct Message: #{message}"
	  uri_path = "#{@dm.uri_path}/events/new.json"
	  response = @dm.make_post_request(uri_path, message)
	  results = JSON.parse(response)
	  results
   end
   
   def generate_message(user_id, message)
	  event = {}
	  event['event'] = {}
	  event['event']['type'] = 'message_create'
	  event['event']['message_create'] = {}
	  event['event']['message_create']['target'] = {}
	  event['event']['message_create']['target']['recipient_id'] = "#{user_id}"

	  message_data = {}
	  message_data['text'] = message

	  event['event']['message_create']['message_data'] = message_data

	  event.to_json
   end
   
end

if __FILE__ == $0 #This script code is executed when running this file.
   user_id = "944480690"
   tweet_link = "https://twitter.com/snowman/status/834221636723277824"
   message = "A Tweet of interest has been posted: #{tweet_link}"
   
   
   sender = SendDirectMessage.new
   #dm_content = sender.generate_message(user_id, message)
   sender.send_direct_message(sender.generate_message(user_id, message))
end