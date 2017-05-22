class GenerateDirectMessageContent

	def generate_welcome_message_default

		welcome_message = "Welcome to a Twitter Direct Message notification system. This system is developed to work with any account that posts geo-tagged Tweets, and is currently using the @USGS_TexasFlood and @USGS_TexasRain Twitter accounts as the 'source' data.
                         \n After sharing your location of interest, you will receive a Direct Message notification when ever the source Twitter account posts a Tweet from that area.
                         \n If you have already enrolled, you can select additional areas of interest. Send a 'list' Direct Message to review your areas of interest.
                         \n If you want to unsubscribe, select that option or send a 'quit' or 'stop' or 'unsubscribe' Direct Message. "

		message = {}
		message['welcome_message'] = {}
		message['welcome_message']['message_data'] = {}
		message['welcome_message']['message_data']['text'] = welcome_message

		quick_reply = {}
		quick_reply['type'] = 'options'
		quick_reply['options'] = []

		option = {}
		option['label'] = 'Pick area of interest from list'
		option['description'] = 'Enroll by selecting a single area of interest from list'
		option['metadata'] = 'pick_from_list'
		quick_reply['options'] << option

		option = {}
		option['label'] = 'Pick area of interest from map'
		option['description'] = 'Enroll by selecting location of interest using a map'
		option['metadata'] = 'select_on_map'
		quick_reply['options'] << option

		option = {}
		option['label'] = 'Learn more about this system'
		option['description'] = 'Select a single area of interest from list'
		option['metadata'] = 'learn_more'
		quick_reply['options'] << option

		option = {}
		option['label'] = 'Unsubscribe'
		option['description'] = 'Unsubscribe from notification system'
		option['metadata'] = 'unsubscribe'
		quick_reply['options'] << option

		message['welcome_message']['message_data']['quick_reply'] = quick_reply

		message.to_json

	end

	#Users are shown this after returning from 'show info' option... A way to serve to other 're-started' dialogs?
	#https://dev.twitter.com/rest/reference/post/direct_messages/welcome_messages/new
	def generate_welcome_message(recipient_id)

		welcome_message = "After sharing your location of interest, you will receive a Direct Message notification when ever the source Twitter account posts a Tweet from that area.
                         \n If you have already enrolled, you can select additional areas of interest by sending an 'add' Direct Message.
                         \n Send a 'list' Direct Message to review your areas of interest.
                         \n If you want to unsubscribe, select that option or send a 'quit' or 'stop' or 'unsubscribe' Direct Message. "

		event = {}
		event['event'] = {}
		event['event']['type'] = 'message_create'
		event['event']['message_create'] = {}
		event['event']['message_create']['target'] = {}
		event['event']['message_create']['target']['recipient_id'] = "#{recipient_id}"

		message_data = {}
		message_data['text'] = welcome_message

		quick_reply = {}
		quick_reply['type'] = 'options'
		quick_reply['options'] = []

		option = {}
		option['label'] = 'Pick area of interest from list'
		option['description'] = 'Enroll by selecting a single area of interest from list'
		option['metadata'] = 'pick_from_list'
		quick_reply['options'] << option

		option = {}
		option['label'] = 'Pick area of interest from map'
		option['description'] = 'Enroll by selecting location of interest using a map'
		option['metadata'] = 'select_on_map'
		quick_reply['options'] << option

		option = {}
		option['label'] = 'List current area(s) of interest'
		option['description'] = 'Show current areas of interest'
		option['metadata'] = 'list'
		quick_reply['options'] << option

		option = {}
		option['label'] = 'Learn more about this system'
		option['description'] = 'Select a single area of interest from list'
		option['metadata'] = 'learn_more'
		quick_reply['options'] << option

		option = {}
		option['label'] = 'Unsubscribe'
		option['description'] = 'Unsubscribe from notification system'
		option['metadata'] = 'unsubscribe'
		quick_reply['options'] << option

		message_data['quick_reply'] = quick_reply

		event['event']['message_create']['message_data'] = message_data

		event.to_json

	end

	def generate_system_info(user_id)

		message_text = "The USGS Texas Water Science Center has created two Twitter accounts that Tweet flood information
                      from across Texas. The @USGS_TexasFlood and @USGS_TexasRain accounts are completely autonomous and
                      broadcast data from over 750 rain and river gauges. These gauges Tweet when they have met or
                      exceeded flood thresholds as defined by the National Weather Service (NWS). For more information
                      about this system, click on: https://blog.twitter.com/2016/using-twitter-as-a-go-to-communication-channel-during-severe-weather-events
                      \n \nThis system was developed to enable Twitter users to receive notifications when gauges from selected areas of interest Tweet. Before this system, users had the option to follow these
                      two accounts and turn on Twitter Tweet notifications. This option was not ideal since users would receive notifications about all gauges, including those hundreds of miles away.
                      \n \nA key detail is that every Tweet posted by these two accounts is geo-tagged, which enables this system to only make notifications when gauges within your area(s) of interest Tweet.
                     "

		#Build DM content.
		event = {}
		event['event'] = {}
		event['event']['type'] = 'message_create'
		event['event']['message_create'] = {}
		event['event']['message_create']['target'] = {}
		event['event']['message_create']['target']['recipient_id'] = "#{user_id}"

		message_data = {}
		message_data['text'] = message_text

		message_data['quick_reply'] = {}
		message_data['quick_reply']['type'] = 'options'

		options = []
		#Not including 'description' option attributes.

		option = {}
		option['label'] = 'Go Back'
		option['metadata'] = "return_to_system"
		options << option

		message_data['quick_reply']['options'] = options

		event['event']['message_create']['message_data'] = message_data
		event.to_json
	end

	#Generates Quick Reply for presenting user a Map via Direct Message.
	#https://dev.twitter.com/rest/direct-messages/quick-replies/location
	def generate_location_map(recipient_id)

		event = {}
		event['event'] = {}
		event['event']['type'] = 'message_create'
		event['event']['message_create'] = {}
		event['event']['message_create']['target'] = {}
		event['event']['message_create']['target']['recipient_id'] = "#{recipient_id}"

		message_data = {}
		message_data['text'] = 'Select your area of interest from the map:'

		message_data['quick_reply'] = {}
		message_data['quick_reply']['type'] = 'location'
		message_data['quick_reply']['location'] = {}
		message_data['quick_reply']['location']['metadata'] = 'map_selection'

		event['event']['message_create']['message_data'] = message_data

		event.to_json
	end

	#Generates Qucik Reply for presenting user a Location List via Direct Message.
	#https://dev.twitter.com/rest/direct-messages/quick-replies/options
	def generate_location_list(recipient_id, list)

		event = {}
		event['event'] = {}
		event['event']['type'] = 'message_create'
		event['event']['message_create'] = {}
		event['event']['message_create']['target'] = {}
		event['event']['message_create']['target']['recipient_id'] = "#{recipient_id}"

		message_data = {}
		message_data['text'] = 'Select your area of interest:'

		message_data['quick_reply'] = {}
		message_data['quick_reply']['type'] = 'options'

		options = []

		list.each do |item|
			option = {}
			option['label'] = item
			option['metadata'] = "location_list_choice: #{item}"
			#Not including 'description' option attributes.
			options << option
		end

		message_data['quick_reply']['options'] = options

		event['event']['message_create']['message_data'] = message_data
		event.to_json

	end

	def generate_subscription_list(user_id, subscriptions)
		event = {}
		event['event'] = {}
		event['event']['type'] = 'message_create'
		event['event']['message_create'] = {}
		event['event']['message_create']['target'] = {}
		event['event']['message_create']['target']['recipient_id'] = "#{user_id}"

		message_data = {}

		list_message = ''

		if subscriptions.count == 0
			list_message = "You are not subscribed to any areas of interest.
                		 \n To select an additional area, send an 'Add' Direct Message.
                         \n If you want to unsubscribe, send a 'Quit' or 'Stop' Direct Message." #'Unsubscribe' is also supported.
		else
			list_message = "You are subscribed to the following areas of interest:"

			subscriptions.each do |area|
				list_message = list_message + "\n * #{area}"
			end

			list_message = list_message + "\n\n To select an additional area, send an 'Add' Direct Message.
                         \n If you want to unsubscribe, send a 'Quit' or 'Stop' Direct Message." #'Unsubscribe' is also supported.
		end

		message_data['text'] = list_message

		event['event']['message_create']['message_data'] = message_data

		event.to_json

	end

	def generate_confirmation(user_id, area_of_interest)
		#Build DM content.
		event = {}
		event['event'] = {}
		event['event']['type'] = 'message_create'
		event['event']['message_create'] = {}
		event['event']['message_create']['target'] = {}
		event['event']['message_create']['target']['recipient_id'] = "#{user_id}"

		message_data = {}
		message_data['text'] = "Thank you for enrolling. Your area of interest has been set to #{area_of_interest}
		\n To select an additional area, send an 'Add' Direct Message.
      \n To review your current areas of interest, send a 'List' Direct Message.
      \n If you want to unsubscribe, send a 'Quit' or 'Stop' Direct Message." #'Unsubscribe' is also supported.

		event['event']['message_create']['message_data'] = message_data

		event.to_json

	end

	def generate_unsubscribe(user_id)

		event = {}
		event['event'] = {}
		event['event']['type'] = 'message_create'
		event['event']['message_create'] = {}
		event['event']['message_create']['target'] = {}
		event['event']['message_create']['target']['recipient_id'] = "#{user_id}"

		message_data = {}
		message_data['text'] = "You have been unsubscribed.
	  \n To re-subscribe either send an 'Add' Direct Message or delete this conversation and send a new Direct Message to see the Welcome Message.  
      \n
		\n Stay safe!"

		event['event']['message_create']['message_data'] = message_data

		event.to_json

	end

end