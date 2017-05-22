require "sinatra"
require 'base64'
require 'yaml'
require 'json'

require_relative "../../app/helpers/event_manager"

class EnrollerApp < Sinatra::Base

	def initialize
		super()
	end

	#Load authentication details
	config_file = './config/config.yaml'
	keys = {}
	
	if File.file?(config_file)
		keys = YAML::load_file(config_file)
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
		hash = OpenSSL::HMAC.digest('sha256', consumer_secret, crc_token)
		return Base64.encode64(hash).strip!
	end

	get '/' do
		"Welcome to the @FloodSocial notification system! <br>
          This websocket component is used for enrolling subscribers into a Twitter-based notification system. <br>
          This component is a consumer of Account Activity API events."
	end

	# Receives challenge response check (CRC).
	get '/webhooks/twitter' do
		crc_token = params['crc_token']

		if not crc_token.nil?

			puts "CRC event with #{crc_token}"
			#puts "consumer secret: #{settings.dm_api_consumer_secret}"
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
		puts "Received event from DM API"

		request.body.rewind
		event = request.body.read

		manager = EventManager.new
		manager.handle_event(event)

		status 200

	end
end