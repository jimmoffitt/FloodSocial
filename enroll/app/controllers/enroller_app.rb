require 'sinatra'
require 'base64'
require 'yaml'
require 'json'

require_relative "../../app/helpers/event_manager"

class EnrollerApp < Sinatra::Base

	def initialize
		super()
	end

	#Load authentication details
	config_file = File.join(File.dirname(__FILE__), '../../config/config_private.yaml')
	keys = {}
	
	if File.file?(config_file)
		keys = YAML::load_file(config_file)
		#puts "keys #{keys}"
		set :dm_api_consumer_key, keys['dm_api']['consumer_key']
		set :dm_api_consumer_secret, keys['dm_api']['consumer_secret']
		set :dm_api_access_token, keys['dm_api']['access_token']
		set :dm_api_access_token_secret, keys['dm_api']['access_token_secret']
	else
		set :dm_api_consumer_key, ENV['CONSUMER_KEY']
		set :dm_api_consumer_secret, ENV['CONSUMER_SECRET']
		set :dm_api_access_token, ENV['ACCESS_TOKEN']
		set :dm_api_access_token_secret, ENV['ACCESS_TOKEN_SECRET']
	end

	#Account Activity API with OAuth

	set :title, 'Twitter Account Activity API client'

	def generate_crc_response(consumer_secret, crc_token)
		puts "consumer_secret: #{consumer_secret}"
		hash = OpenSSL::HMAC.digest('sha256', consumer_secret, crc_token)
		return Base64.encode64(hash).strip!
	end

	get '/' do
		"<p><b>Welcome to the @FloodSocial notification system!</b></p>
          
<p>This prototype is a proof-of-concept example for enrolling subscribers into a geo-aware, Twitter-based notification system. This websocket-based component is a consumer of Account Activity API events, and uses Direct Message (DM) API to communicate to recipient account.</p>
<p>This demo is currently using @USGS_TexasFlood and @USGS_TexasRain as its 'source' Twitter accounts. However, this system can be tied to any Twitter account(s) that posts geo-tagged Tweets.</p>

<p>This system is not intended for operational notifications, and the alert components are usually only running during tests and demos...</p>

<p><b><i>Take a tour of the demo by sending a Direct Message (DM) to @FloodSocial.</i></b></p>
          
<p>While this 'Enroller' component essentially runs 24/7, the components that listen for Tweets of (subscribed) interest and send DMs to recipients are usually only running during development, testing, and demos... </p>
<p>Pro Tip: pick an area (with map) outside of Texas and you'll never receive a notification (unless you are participating in demo!). </p>

    "
	end

	# Receives challenge response check (CRC).
	get '/webhooks/twitter' do
		crc_token = params['crc_token']

		if not crc_token.nil?

			puts "CRC event with #{crc_token}"
			puts "headers: #{headers}"
			puts headers['X-Twitter-Webhooks-Signature']

			response = {}
			response['response_token'] = "sha256=#{generate_crc_response(settings.dm_api_consumer_secret, crc_token)}"

			body response.to_json
		end

		status 200

	end

	# Receives DM events.
	post '/webhooks/twitter' do
		#puts "Received event(s) from DM API"
		request.body.rewind
		events = request.body.read

		manager = EventManager.new
		manager.handle_event(events)

		status 200
	end
end
