class GenerateDirectMessageContent

	def generate_greeting

		greeting = "Welcome to a Twitter-based, geo-aware notification system. This system is developed to work with any account that posts geo-tagged Tweets, and is currently using the @USGS_TexasFlood and @USGS_TexasRain Twitter accounts as the 'source' data.\n\nYou can enroll in the system by adding an area of interest. After enrolling will receive a Direct Message notification whenever a source Twitter account posts a Tweet from that area. "
		greeting

	end
	
	def generate_main_message
		greeting = "Welcome to a Twitter-based, geo-aware notification system. "
		greeting

	end

	def generate_options_menu
		quick_reply = {}
		quick_reply['type'] = 'options'
		quick_reply['options'] = []

		option = {}
		option['label'] = '+ Add area of interest'
		option['description'] = 'Enroll by selecting area of interest'
		option['metadata'] = 'add_area'
		quick_reply['options'] << option
		
		option = {}
		option['label'] = '䷀ List current area(s) of interest'
		option['description'] = 'Show current areas of interest'
		option['metadata'] = 'list'
		quick_reply['options'] << option
		
		option = {}
		option['label'] = '☞ Learn more about this system'
		option['description'] = 'See a detailed system description and links to related information'
		option['metadata'] = 'learn_more'
		quick_reply['options'] << option

		option = {}
		option['label'] = '☔ Help'
		option['description'] = 'Help with system commands'
		option['metadata'] = 'help'
		quick_reply['options'] << option
		
		option = {}
		option['label'] = '✂ Unsubscribe'
		option['description'] = 'Unsubscribe from notification system'
		option['metadata'] = 'unsubscribe'
		quick_reply['options'] << option
		
		quick_reply
	end

	#New users will be served this.
	#https://dev.twitter.com/rest/reference/post/direct_messages/welcome_messages/new
	def generate_welcome_message_default

		message = {}
		message['welcome_message'] = {}
		message['welcome_message']['message_data'] = {}
		message['welcome_message']['message_data']['text'] = generate_greeting

		message['welcome_message']['message_data']['quick_reply'] = generate_options_menu

		message.to_json

	end

	#Users are shown this after returning from 'show info' option... A way to serve to other 're-started' dialogs?
	#https://dev.twitter.com/rest/reference/post/direct_messages/welcome_messages/new
	def generate_welcome_message(recipient_id)

		event = {}
		event['event'] = {}
		event['event']['type'] = 'message_create'
		event['event']['message_create'] = {}
		event['event']['message_create']['target'] = {}
		event['event']['message_create']['target']['recipient_id'] = "#{recipient_id}"

		message_data = {}
		message_data['text'] = generate_main_message

		message_data['quick_reply'] = generate_options_menu

		event['event']['message_create']['message_data'] = message_data

		event.to_json

	end

	#Users are shown this after returning from 'show info' option... A way to serve to other 're-started' dialogs?
	#https://dev.twitter.com/rest/reference/post/direct_messages/welcome_messages/new
	def generate_system_maintenance_welcome

		message = {}
		message['welcome_message'] = {}
		message['welcome_message']['message_data'] = {}
		message['welcome_message']['message_data']['text'] = "System going under maintenance... Come back soon..."

		message.to_json

	end

	def generate_system_info(recipient_id)

		message_text = "The USGS Texas Water Science Center has created two Twitter accounts that Tweet flood information from across Texas. The @USGS_TexasFlood and @USGS_TexasRain accounts are completely autonomous and broadcast data from over 750 rain and river gauges. These gauges Tweet when they have met or exceeded flood thresholds as defined by the National Weather Service (NWS).\nFor more information about this system, click on: https://blog.twitter.com/2016/using-twitter-as-a-go-to-communication-channel-during-severe-weather-events\n\nThis system was developed to enable Twitter users to receive notifications when gauges from selected areas of interest Tweet. Before this system, users had the option to follow these two accounts and turn on Twitter Tweet notifications. This option was not ideal since users would receive notifications about all gauges, including those hundreds of miles away.\n\u2744\nA key detail is that every Tweet posted by these two accounts is geo-tagged, which enables this system to only make notifications when gauges within your area(s) of interest Tweet.\n\u2744\nFor sample code, see https://github.com/jimmoffitt/FloodSocial"

		#Build DM content.
		event = {}
		event['event'] = {}
		event['event']['type'] = 'message_create'
		event['event']['message_create'] = {}
		event['event']['message_create']['target'] = {}
		event['event']['message_create']['target']['recipient_id'] = "#{recipient_id}"

		message_data = {}
		message_data['text'] = message_text

		message_data['quick_reply'] = {}
		message_data['quick_reply']['type'] = 'options'

		options = []
		
		option = {}
		option['label'] = '⌂ Home'
		option['metadata'] = "return_to_system"
		options << option

		message_data['quick_reply']['options'] = options

		event['event']['message_create']['message_data'] = message_data
		event.to_json
	end

	def generate_system_help(recipient_id)

		message_text = "This system supports several commands. Commands are made by sending a Direct Message including these (case-insensitive) keywords:
                      \n\u2744 'Home', 'Hello', or 'Main' -- go back to main menu.\n\u2744 'Add' -- Add another area of interest. \n\u2744 'List' -- Review what areas of interest you are subscribed to. \n\u2744 'About' -- Learn more about the system and follow links to more information. \n\u2744 'Help' -- See this help screen. \n\u2744 'Quit' or 'Stop' or 'Unsubscribe' -- Unsubscribe from system, removing all areas of interest."

		#Build DM content.
		event = {}
		event['event'] = {}
		event['event']['type'] = 'message_create'
		event['event']['message_create'] = {}
		event['event']['message_create']['target'] = {}
		event['event']['message_create']['target']['recipient_id'] = "#{recipient_id}"

		message_data = {}
		message_data['text'] = message_text

		message_data['quick_reply'] = {}
		message_data['quick_reply']['type'] = 'options'

		options = []
		#Not including 'description' option attributes.

		option = {}
		option['label'] = '⌂ Home'
		option['metadata'] = "return_to_system"
		options << option

		message_data['quick_reply']['options'] = options

		event['event']['message_create']['message_data'] = message_data
		event.to_json
	end
	
	
	
	
	#Generates Quick Reply for picking method for selecting area of inteerst: map or list
	def generate_location_method(recipient_id)

		message_text = "Select method for (privately) sharing location:"

		#Build DM content.
		event = {}
		event['event'] = {}
		event['event']['type'] = 'message_create'
		event['event']['message_create'] = {}
		event['event']['message_create']['target'] = {}
		event['event']['message_create']['target']['recipient_id'] = "#{recipient_id}"

		message_data = {}
		message_data['text'] = message_text

		message_data['quick_reply'] = {}
		message_data['quick_reply']['type'] = 'options'

		options = []

		option = {}
		option['label'] = '+ Add area of interest from list'
		#option['description'] = 'Enroll by selecting an area of interest from list'
		option['metadata'] = 'pick_from_list'
		options << option

		option = {}
		option['label'] = '+ Add area of interest from map'
		#option['description'] = 'Enroll by selecting an interest using a map'
		option['metadata'] = 'select_on_map'
		options << option

		option = {}
		option['label'] = '⌂ Home'
		#option['description'] = 'Back to main menu'
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

	def generate_subscription_list(recipient_id, subscriptions)
		event = {}
		event['event'] = {}
		event['event']['type'] = 'message_create'
		event['event']['message_create'] = {}
		event['event']['message_create']['target'] = {}
		event['event']['message_create']['target']['recipient_id'] = "#{recipient_id}"

		message_data = {}

		list_message = ''

		if subscriptions.count == 0
			list_message = "You are not subscribed to any areas of interest.
                		 \n To select an additional area, send an 'Add' Direct Message.
                         \n If you want to unsubscribe, send a 'Quit' or 'Stop' Direct Message." #'Unsubscribe' is also supported.
		else
			list_message = "You are subscribed to the following areas of interest:"

			subscriptions.each do |area|
				list_message = list_message + "\n\u2744 #{area}"
			end

		end

		message_data['text'] = list_message

		message_data['quick_reply'] = {}
		message_data['quick_reply']['type'] = 'options'

		options = []
		#Not including 'description' option attributes.

		option = {}
		option['label'] = '+ Add area of interest'
		option['description'] = 'Enroll by selecting an area of interest'
		option['metadata'] = 'add_area'
		options << option

		#option = {}
		#option['label'] = 'Pick area of interest from map'
		#option['description'] = 'Enroll by selecting location of interest using a map'
		#option['metadata'] = 'select_on_map'
		#options << option

		option = {}
		option['label'] = '☞ Learn more about this system'
		option['description'] = 'See a detailed system description and links to related information'
		option['metadata'] = 'learn_more'
		options << option

		option = {}
		option['label'] = '☔ Help'
		option['description'] = 'Help with system commands'
		option['metadata'] = 'help'
		options << option

		option = {}
		option['label'] = '✂ Unsubscribe'
		option['description'] = 'Unsubscribe from notification system'
		option['metadata'] = 'unsubscribe'
		options << option

		#option = {}
		#option['label'] = 'Home'
		#option['metadata'] = "return_to_system"
		#options << option

		message_data['quick_reply']['options'] = options

		event['event']['message_create']['message_data'] = message_data

		event.to_json

	end

	def generate_confirmation(recipient_id, area_of_interest)
		#Build DM content.
		event = {}
		event['event'] = {}
		event['event']['type'] = 'message_create'
		event['event']['message_create'] = {}
		event['event']['message_create']['target'] = {}
		event['event']['message_create']['target']['recipient_id'] = "#{recipient_id}"

		message_data = {}
		message_data['text'] = "You have added an area of interest: #{area_of_interest}"
		#\n To select an additional area, send an 'Add' Direct Message.
    #  \n To review your current areas of interest, send a 'List' Direct Message.
    #  \n If you want to unsubscribe, send a 'Quit' or 'Stop' Direct Message." #'Unsubscribe' is also supported.

		message_data['quick_reply'] = {}
		message_data['quick_reply']['type'] = 'options'

		options = []
		#Not including 'description' option attributes.

		option = {}
		option['label'] = '+ Add area of interest'
		option['description'] = 'Enroll by selecting an area of interest'
		option['metadata'] = 'add_area'
		options << option

		#option = {}
		#option['label'] = 'Pick area of interest from map'
		#option['description'] = 'Enroll by selecting location of interest using a map'
		#option['metadata'] = 'select_on_map'
		#options << option

		option = {}
		option['label'] = '䷀ List current area(s) of interest'
		option['description'] = 'Show current areas of interest'
		option['metadata'] = 'list'
		options << option
		
		option = {}
		option['label'] = '☞ Learn more about this system'
		option['description'] = 'See a detailed system description and links to related information'
		option['metadata'] = 'learn_more'
		options << option

		option = {}
		option['label'] = '☔ Help'
		option['description'] = 'Help with system commands'
		option['metadata'] = 'help'
		options << option

		option = {}
		option['label'] = '✂ Unsubscribe'
		option['description'] = 'Unsubscribe from notification system'
		option['metadata'] = 'unsubscribe'
		options << option

		#option = {}
		#option['label'] = 'Home'
		#option['metadata'] = "return_to_system"
		#options << option

		message_data['quick_reply']['options'] = options
		
		

		event['event']['message_create']['message_data'] = message_data

		event.to_json

	end
	
	def generate_message(recipient_id, message)

			message_text = message

			#Build DM content.
			event = {}
			event['event'] = {}
			event['event']['type'] = 'message_create'
			event['event']['message_create'] = {}
			event['event']['message_create']['target'] = {}
			event['event']['message_create']['target']['recipient_id'] = "#{recipient_id}"

			message_data = {}
			message_data['text'] = message_text

			event['event']['message_create']['message_data'] = message_data
			event.to_json
	end

	def generate_unsubscribe(recipient_id)

		event = {}
		event['event'] = {}
		event['event']['type'] = 'message_create'
		event['event']['message_create'] = {}
		event['event']['message_create']['target'] = {}
		event['event']['message_create']['target']['recipient_id'] = "#{recipient_id}"

		message_data = {}
		message_data['text'] = "You have been unsubscribed.\n\n To re-subscribe either send an 'Add' Direct Message or delete this conversation and send a new Direct Message to see the Welcome Message.
      \n
		\n Stay safe and dry!"

		event['event']['message_create']['message_data'] = message_data

		event.to_json

	end
	
	
	

end
