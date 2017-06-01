#POST requests to /webhooks/twitter arrive here.
#Twitter Account Activity API send events as POST requests with DM JSON payloads.

require 'json'
#Two helper classes... 
require_relative 'send_direct_message'
require_relative 'power_track_rules_manager'

class EventManager
	@@previous_event_id = 0

	COMMAND_MESSAGE_LIMIT = 100	#Simplistic way to detect an incoming, short, 'commmand' DM.
	
	attr_accessor :DMsender, :RulesManager

	def initialize
		#puts 'Creating SendDirectMessage object'
		@DMSender = SendDirectMessage.new
		#External 'things' this object can trigger...
		@RulesManager = PowerTrackRulesManager.new
	end

	#responses are based on options' Quick Reply metadata settings.
	#pick_from_list, select_on_map, location list items (e.g. 'location_list_choice: Austin' or 'Fort Worth')
	#map_selection (triggers a fetch of the shared coordinates)

	def handle_event(events)

		#puts "Event handler processing: #{events}"

		events = JSON.parse(events)

		if events.key? ('direct_message_events')

			dm_events = events['direct_message_events']

			dm_events.each do |dm_event|
				
				#puts "id: #{@@previous_event_id}"

				if dm_event['type'] == 'message_create'

					#Is this a response? Test for the 'quick_reply_response' key.
					is_response = dm_event['message_create'] && dm_event['message_create']['message_data'] && dm_event['message_create']['message_data']['quick_reply_response']

					if is_response
						response = dm_event['message_create']['message_data']['quick_reply_response']['metadata']
						user_id = dm_event['message_create']['sender_id']

						#puts "User #{user_id} answered with #{response}"

						if response == 'help'
							@DMSender.send_system_help(user_id)
						elsif response == 'learn_more'
							@DMSender.send_system_info(user_id)
						elsif response == 'return_to_system'
							@DMSender.send_welcome_message(user_id)
						elsif response == 'add_area'
							@DMSender.send_area_method(user_id)
						elsif response == 'select_on_map'
							@DMSender.send_map(user_id)
						elsif response == 'pick_from_list'
							@DMSender.send_location_list(user_id)
						elsif response.include? 'location_list_choice'
							location_choice = response['location_list_choice: '.length..-1]
							coordinates = []
							coordinates = @RulesManager.add_rule_for_list_subscription(user_id, location_choice)
							location_choice = "#{location_choice} (a 25-mile radius circle centered at #{coordinates[0]}, #{coordinates[1]} to be specific)"
							@DMSender.send_confirmation(user_id, location_choice)
						elsif response == 'map_selection'
							#Navigate and extract the long lat details

							#Do we have a Twitter Place or exact coordinates....?
							location_type = dm_event['message_create']['message_data']['attachment']['location']['type']

							if location_type == 'shared_coordinate'
								coordinates = dm_event['message_create']['message_data']['attachment']['location']['shared_coordinate']['coordinates']['coordinates']
								location_choice = "25-mile radius circle centered at #{coordinates[0].round(4)}, #{coordinates[1].round(4)}."
							else
								coordinates = dm_event['message_create']['message_data']['attachment']['location']['shared_place']['place']['centroid']
								place_name = dm_event['message_create']['message_data']['attachment']['location']['shared_place']['place']['name']
								location_choice = "25-mile radius circle centered on #{place_name} (with centroid of #{coordinates[0].round(4)}, #{coordinates[1].round(4)})."
							end

							@RulesManager.add_rule_for_map_subscription(user_id, coordinates[0].round(4), coordinates[1].round(4), location_choice)

							@DMSender.send_confirmation(user_id, location_choice)
						elsif response == 'list'
							puts "Retrieve current config for user #{user_id}. "
							subscriptions = @RulesManager.get_subscriptions(user_id)
							#puts "Subscriptions: #{subscriptions}"
							@DMSender.send_subscription_list(user_id, subscriptions)
						elsif response == 'unsubscribe'
							puts 'unsubscribe'
							@RulesManager.delete_subscription(user_id)
							@DMSender.send_unsubscribe(user_id)
						else #we have an answer to one of the above.
							puts "UNHANDLED user response: #{response}"
						end
					else
						#Since this DM is not a response to a QR, let's check for other 'action' commands
						#puts 'Received a command/question DM? Need to track conversation stage?'

						request = dm_event['message_create']['message_data']['text']
						user_id = dm_event['message_create']['sender_id']

						if request.length < COMMAND_MESSAGE_LIMIT and (request.downcase.include? 'home' or request.downcase.include? 'add' or request.downcase.include? 'main' or request.downcase.include? 'hello')
							puts 'Send QR to add an area'
							#Send QR for which 'select area' method
							@DMSender.send_welcome_message(user_id)

						elsif request.length < COMMAND_MESSAGE_LIMIT and (request.downcase.include? 'unsubscribe' or request.downcase.include? 'quit' or request.downcase.include? 'stop')
							puts 'unsubscribe'
							@RulesManager.delete_subscription(user_id)
							@DMSender.send_unsubscribe(user_id)

						elsif request.length < COMMAND_MESSAGE_LIMIT and request.downcase.include? 'list'
							puts "Retrieve current config for user #{user_id}. "
							area_names = @RulesManager.get_subscriptions(user_id)
							#puts "EventManager: left Rules manager with #{area_names}"
							@DMSender.send_subscription_list(user_id, area_names)
							
						elsif request.length < COMMAND_MESSAGE_LIMIT and (request.downcase.include? 'about')
							puts "Send 'learn more' content"
							@DMSender.send_system_info(user_id)
						elsif request.length < COMMAND_MESSAGE_LIMIT and (request.downcase.include? 'help')
							puts "Send 'help' content"
							@DMSender.send_system_help(user_id)
							
							
						else
							#"Listen, I only understand a few commands like: Add, List, Quit"
						end
					end
				else
					puts "Hey a new, unhandled type has been implemented on the Twitter side."
				end
			end
		else
			puts "Received test JSON."
		end
	end
end