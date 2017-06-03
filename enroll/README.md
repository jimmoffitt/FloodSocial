# Enrolling Users into a Geo-aware Twitter Notification System
## Building user services with the Twitter Direct Message and Account Activity APIs.

+ [Introduction](#intro)
+ [Getting Started](#getting_started)
+ [Demo Design](#demo_design)
+ [Development Environment, Tips, and Tools](#demo_dev)
+ [Tour the Demo](#try_app)
+ [Sample Code](#sample_code)
+ [Deploying Demo](#deploying)

## Introduction <a id="intro" class="tall">&nbsp;</a>

In this tutorial we are going to build a geo-enabled notification system based on Twitter Direct Messages. The _alarms_ that trigger notifications will be Tweets that are geo-tagged in an area of interest. System subscribers will privately share their locations of interest using new features of the Twitter Direct Message API, along with help of the new Account Activity API. 

The fundamental user-story is: _"As a Twitter user I want to receive a Direct Message when a Twitter account I follow posts a Tweet of interest geo-tagged in an area of interest."_ 

Notifications will come in the form of Twitter Direct Messages, the Twitter 'source' account(s) will post Tweets associated with an exact location, and areas of interest will be defined as a 25-mile circle centered on a location shared by the Twitter user. Users will be given two methods to *privately share* their location: select a point on a map, or chose from a list of locations. For this tutorial the location lists will consist of city names, and the corresponding areas will be based on the geographic center of those cities. 

The fundamental goal of this tutorial is to demonstrate how to enable Twitter users to share their location of interest via a private Direct Message. The component we are building here is based on the Twitter Direct Message (DM) and Account Activity (AA) APIs. This component will be referred as an *Enroller*, a webhook-based component that enables Twitter users to subscribe to the system. This *Enroller* is one of two components that make up the complete notification system:

  + Enroller - A webhook consumer that manages Direct Message events that are delivered via the Twitter Account Activity API. This new API currently supports Direct Messages, but will soon also support Tweet and select Engagement events. Since the Accounty Activity API is webhook-based it opens the door to a lot of new Twitter 'system' design and use-cases. For this demo, the Enroller will both receive event messages from Twitter and also sending messages to enrollees. The Enroller creates and manages subscriber-specific details (in this case PowerTrack filters), which affect which Tweets are consumed from the Twitter real-time Firehose. The Enroller is a Ruby Sinatra-based web application hosted on Heroku. 
  
  + Tweet Alert - For this prototype, this is a simple Python script that manages both of these concerns: 
  	+ Alarm listener: monitors real-time stream for Tweets of (geo) interest, triggers notification when there is a location-of-interest match.
  	+ Notifier: send Direct Message notifications to subscribers. 
  
See [HERE](https://github.com/jimmoffitt/FloodSocial) if you are interested in the other two components.
  
We'll start off with a discussion on how to get started with the Twitter Direct Message and Account Activity APIs. While the Direct Message API provides the communication channel, the webhook-based Account Activity API enables client-specific applications manage the real-time Twitter conversations. The Account Activity API send Direct Message events via webhooks to your web app, enabling you to build client-specific responses. Since conversations are happening with Direct Message, it is a private conservation. 

<
After building this tutorial and app, I see these new APIs as a way to build custom user interfaces right into the Twitter platform. That capability enables a lot of amazing new use-cases for the platform. 
> 
      
## Getting started with the Direct Message and Account Activity APIs <a id="getting_started" class="tall">&nbsp;</a>

< 
Many moving pieces. Creating a Twitter app with Account Activity API access. Building a webhook consumer application. This consumer will receive Direct Message events from Twitter. The consumer will manage incoming events, receiving client requests and creating repsonses. 
>

A great place to start is our API documentation:

+ Getting Started with the Account Activity API https://dev.twitter.com/webhooks/getting-started
+ Twitter Webhook APIs https://dev.twitter.com/webhooks
+ Account Activity API documentation https://dev.twitter.com/webhooks/account-activity
+ Direct Message API methods: https://dev.twitter.com/rest/direct-messages

To help you put all that information together, check out our [Twitter Direct Message API Playbook].

As a developer, here are the steps you'll take:

Configuring Twitter Webhooks
+ Create a Twitter Application, and have it enabled with the Account Activity API. For now, you'll need to apply for Account Activity API access [HERE](https://gnipinc.formstack.com/forms/account_activity_api_configuration_request_form).
+ Subscribe your consumer web app using the Account Activity API
+ Create a default Welcome Message 

Developing Webhook Consumer
+ Stand-up a web application that will be your webhook consumer 
+ Implement a consumer Challenge Response Check (CRC) method
+ Implement a consumer webhook event manager

Before we dig more into those steps, we'll describe the demo design that drove the development of this tutorial.

## Enroller Design <a id="design" class="tall">&nbsp;</a>

For this tutorial, a more specific user-story goes like:

   _"I would like to receive a Twitter Direct Message if there are official flood-related Tweets within my area of internet"_

A notification system that enables subscribers to privately share their location of interest, and receive private Direct Message notifications When geo-tagged Tweets with select attributes are posted within area(s) of interest.

This particular demo will use an existing Twitter-based data exchange system deployed by the USGS Texas Water Science Center (TXWSC). In 2016 two autonomous Twitter accounts were launched: @USGS_TexasFlood and @USGS_TexasRain. These accounts broadcast geo-tagged Tweets when any of ~750 sites around Texas record potential and current flood conditions. You can read more about this system at https://blog.twitter.com/2016/using-twitter-as-a-go-to-communication-channel-during-severe-weather-events. Although this demo is using the USGS Texas-based system, the techniques and APIs demonstrated here are agnostic beyond working with geo-tagged Tweets. This particular demo is based on geographical information, but other listening and user interest criteria is equally applicable. 

The main purposes of the Enroller are:

+ Introduce the user to the system.
+ Provide two ways to share locations of interest: 
  + Using a map.
  + Picking from a list of locations.
+ Enable subscribers to add multiple locations.   
+ Enable subscribers to review their current areas of interest.
+ Enable subscribers to unsubscribe.

From a developer's prespective, other desirable features included:
+ Ability to import a list of locations to display to user.
+ Provide Direct Message commands to use system.
    + DM 'Add' to add a new area of interest.
    + DM 'List' to review current areas of interest.
    + DM 'About' to learn more about system.
+ Abstract subscription details (user id and locations) into PowerTrack Rules.
    + This design was picked to keep the enroller light-weight by not implementing native data persistence. All user enrollments are stored remotely as a real-time PowerTrack ruleset. 

## Tour the Demo <a id="try_app" class="tall">&nbsp;</a>

To check out the demo simply send a Direct Message to @FloodSocial. When you do that you will see a Welcome Message with options to select a location of interest, learn more about the system, or if you have previously enrolled, unsubscribe.

< WELCOME MESSAGE SCREENSHOT >

After you have navigated past the Welcome Message you can send 'command' Direct Messages to add more areas of interest, to list your current areas, or to unsubscribe.

< MORE SCREENSHOTS? >

## Development Environment, Tips, and Tools <a id="demo_dev" class="tall">&nbsp;</a>




## Sample Code <a id="sample_code" class="tall">&nbsp;</a>

### Enroller helper objects
  + Scripts for configuration webhooks
  + Direct Message Event Manager 
  + Direct Message Content Manager
  + Direct Message Sender
  + Rule manager: takes user submissions and converts those to PowerTrack rules and adds to stream.

### Scripts for configuration webhooks


< THIS RUBY SCRIPT WAS WRITTEN TO HELP MANAGE THE 'SECURE WEBHOOKS' STEPS >

+ Using AA API, Assign webhook URL, generate webhook ID. 

 ```ruby
  def set_webhook_config(url)
		uri_path = "/1.1/account_activity/webhooks.json?url=#{url}"
		response = @twitter_api.make_post_request(uri_path,nil)
		results = JSON.parse(response)
    
    #Response provides the new Webhook ID
		@webhook_id = results['id']
		@webhook_url = results['url']
		puts "Created webhook instance with webhook_id: #{@webhook_id} | pointing to #{@webhook_url}"

		results
	end
  ```

+ Using DM API, create Welcome Message

```json
{
  "welcome_message": {
    "message_data": {
      "text": "Welcome. This system is developed to work with any account that posts geo-tagged Tweets, and is currently using the @USGS_TexasFlood and @USGS_TexasRain Twitter accounts as the 'source' data.\n\nAfter sharing your location of interest, you will receive a Direct Message notification whenever a source Twitter account posts a Tweet from that area.                         ",
      "quick_reply": {
        "type": "options",
        "options": [
          {
            "label": "Pick area of interest from list",
            "description": "Enroll by selecting a single area of interest from list",
            "metadata": "pick_from_list"
          },
          {
            "label": "Pick area of interest from map",
            "description": "Enroll by selecting location of interest using a map",
            "metadata": "select_on_map"
          },
          {
            "label": "List current area(s) of interest",
            "description": "Show current areas of interest",
            "metadata": "list"
          },
          {
            "label": "Learn more about this system",
            "description": "See a detailed system description and links to related information",
            "metadata": "learn_more"
          },
          {
            "label": "Help",
            "description": "Help with system commands",
            "metadata": "help"
          },
          {
            "label": "Unsubscribe",
            "description": "Unsubscribe from notification system",
            "metadata": "unsubscribe"
          }
        ]
      }
    }
  }
}

```

Response:

```json
{
  "welcome_message": {
    "id": "868179877014290436",
    "created_timestamp": "1495825187339",
    "message_data": {
      "text": "Welcome. This system is developed to work with any account that posts geo-tagged Tweets, and is currently using the @USGS_TexasFlood and @USGS_TexasRain Twitter accounts as the 'source' data.\n\nAfter sharing your location of interest, you will receive a Direct Message notification whenever a source Twitter account posts a Tweet from that area.",
      "entities": {
        "hashtags": [
          
        ],
        "symbols": [
          
        ],
        "user_mentions": [
          {
            "screen_name": "USGS_TexasFlood",
            "name": "USGS TX FloodWatch",
            "id": 7.1520957480278e+17,
            "id_str": "715209574802784256",
            "indices": [
              116,
              132
            ]
          },
          {
            "screen_name": "USGS_TexasRain",
            "name": "USGS TX RainWatch",
            "id": 7.1521146495332e+17,
            "id_str": "715211464953319424",
            "indices": [
              137,
              152
            ]
          }
        ],
        "urls": [
          
        ]
      },
      "quick_reply": {
        "type": "options",
        "options": [
          {
            "label": "Pick area of interest from list",
            "metadata": "pick_from_list",
            "description": "Enroll by selecting a single area of interest from list"
          },
          {
            "label": "Pick area of interest from map",
            "metadata": "select_on_map",
            "description": "Enroll by selecting location of interest using a map"
          },
          {
            "label": "List current area(s) of interest",
            "metadata": "list",
            "description": "Show current areas of interest"
          },
          {
            "label": "Learn more about this system",
            "metadata": "learn_more",
            "description": "See a detailed system description and links to related information"
          },
          {
            "label": "Help",
            "metadata": "help",
            "description": "Help with system commands"
          },
          {
            "label": "Unsubscribe",
            "metadata": "unsubscribe",
            "description": "Unsubscribe from notification system"
          }
        ]
      }
    }
  }
}
```

+ Using AA API, add subscriber (webhook ID).







#### CRC Method 

As described [HERE](https://dev.twitter.com/webhooks/securing), Twitter will issue periodic Challenge Response Checks (CRC) and confirm the client app possesses the correct app secret. 


 + Implement GET method to support CRC.

``` ruby
require 'base64'

def generate_crc_response(consumer_secret, crc_token)
  hash = OpenSSL::HMAC.digest('sha256', consumer_secret, crc_token)
  return Base64.encode64(hash).strip!
end

# Receives challenge response check (CRC).
get '/webhooks/twitter' do
  crc_token = params['crc_token']
  response = {}
  response['response_token'] = "sha256=#{generate_crc_response(settings.dm_api_consumer_secret, crc_token)}"
  status 200
end

```

If not, webhook events will cease. While you are developing your webhook consumer you will need a tool that initiates a CRC check. During development it is likely that your web app will not be running during a Twitter challenge, and you'll need to trigger a challenge so you can re-establish webhook connectivity.






### Webhook Event Receiver

For this demo we are buidling a web application with Sinatra. With that framework we build a fundamental HTTP route that receives POST requests made to https://floodsocial.io/webhooks/twitter.

Direct Message (DM) events will arrive here (via webhooks) everytime a user sends a Direct Message. Actually, there is one exception: when a user first selects your account they will be served a **default** Welcome Message. For example, when an account first selects @FloodSocial to send a DM to, a pre-defined Welcome Message is presented to the user. These Welcome Messages offer the user a first set of options to pick. 

```ruby
post '/webhooks/twitter' do
  puts "Received event from DM API"
  request.body.rewind
  event = request.body.read

  manager = EventManager.new
  manager.handle_event(event)
  status 200

end

```

Generating Content

```ruby
message_data = {}
message_data['text'] = {}

message_data['quick_reply'] = 
message_data['quick_reply']['type'] = 'options'

options = {} 

message_data['quick_reply']['options'] = options



```


Generating options



#### Direct Message Event Manager 

```ruby

def handle_event(events)
  events = JSON.parse(events)
  
  if events.key? ('direct_message_events')
    dm_events = events['direct_message_events']
    dm_events.each do | dm_event |
      if dm_event['type'] == 'message_create'
        #Is this a response? Test for the 'quick_reply_response' key.
        is_response = dm_event['message_create'] && dm_event['message_create']['message_data'] && dm_event['message_create']['message_data']['quick_reply_response']
        if is_response 
          response = dm_event['message_create']['message_data']['quick_reply_response']['metadata']
          user_id = dm_event['message_create']['sender_id']	  
          puts "User #{user_id} answered with #{response}"
          #Handle event
        else
          #Since this DM is not a response to a QR, let's check for other 'action' commands
          request = dm_event['message_create']['message_data']['text']
          user_id = dm_event['message_create']['sender_id']
          #Handle request/command
        end  
    end   
  end
end
```

### Direct Message Content Manager

```ruby 
def generate_confirmation(user_id, area_of_interest)
  #Build DM content.
  event = {}
  event['event'] = {}
  event['event']['type'] = 'message_create'
  event['event']['message_create'] = {}
  event['event']['message_create']['target'] = {}
  event['event']['message_create']['target']['recipient_id'] = "#{user_id}"

  message_data = {}
  message_data['text'] = "Thank you for enrolling."
  event['event']['message_create']['message_data'] = message_data

  event.to_json #return this... 

end
```



### Direct Message Sender

```ruby
#Send a DM back to user.
#https://dev.twitter.com/rest/reference/post/direct_messages/events/new
def send_direct_message(message)
  uri_path = "#{@dm.uri_path}/events/new.json"
  response = @dm.make_post_request(uri_path, message)
  results = JSON.parse(response)
  results #return this... 
end
```


### Rule Manager





## Deploying Demo <a id="deploying" class="tall">&nbsp;</a>

Now that the webhook consumer and Direct Message event manager is written and tested, it is time to deploy the application to a 'real' web server. As part of the transition from development to production, we will be porting the 'host' account to a @FloodSocial account. For this demo we will be deploying the application to Heroku at https://floodsocial.herokuapp.com/. One potential issue with hosting on Heroku may be that the server may go to sleep and thus introduce enough latency to fail the Twitter Account Activity CRC test. We'll keep an eye on that and explore Heroku plans that prevent this from happening. 

For this tutorial, I decided to develop the app under one account, then deploy the production version under a second one. You may choose to use a single account for both development and production. 


We'll take the following steps to deploy to Heroku:

+ Create the production Twitter app with Account Activity API enabled, generate keys and tokens.
+ Update code to use keys and tokens of the production app. 
+ Stand-up Web app.
  + Implement GET route to receive CRC requests from Twitter via the Account Activity API.
  + Implement POST route to receive Direct Message events via the Account Activity API.
+ Set Webhook Configuration.
  + Make POST request with Webhook consumer URL. 
  
 



Generate Webhook ID and subscribe that and the Webhook 'event reciever' URL with the Twitter Account Activity API. 
  + Register your webhook URL with your app using POST account_activity/webhooks.
  + Use the returned webhook_id to add user subscriptions with POST account_activity/webhooks/:webhook_id/subscriptions.
  
  
+ Set Default Welcome Message. 
  + Review Welcome Message contents and make any neccessary revisions.  



### Some handy Heroku commands:

You can put the app in maintenance mode, which makes it stop serving requests:

heroku maintenance:on --app floodsocial
heroku maintenance:off --app floodsocial

heroku restart worker.1 

heroku ps:scale web=0
heroku ps:scale web=1


### Setting up a maintenance mode Welcome Message

```json
{
  "welcome_messages": [
    {
      "id": "868169781060317187",
      "created_timestamp": "1495822780276",
      "message_data": {
        "text": "System going under maintenance... Come back soon...",
        "entities": {
          "hashtags": [
            
          ],
          "symbols": [
            
          ],
          "user_mentions": [
            
          ],
          "urls": [
            
          ]
        }
      }
    }
  ]
}
```







================================================
Demo Notes:

+ Webhook consumer - Subscription Manager, private user data
+ Real-time PowerTrack with Rules API
  + Real-time PT stream consumer   
  + PowerTrack Rules Manager
+ DM Notifier
  


  
 + Develop Webhook (event) consumer.
  + Implement GET method to support CRC.
  + Implement POST method to receive webhook events from Twitter.
  + Build webhook event processor, forking conversations and building Direct Message content (welcome messages and quick replies).
  
  Fundamental pieces:
    + Configuration tools.
    + Event Manager - listening for responses and commands.
    + DM Sender - Asking questions and answering questions. 
    

[] Deploy Webhook consusumer.
    [] Developing with localhost
        [] ngrok and pagekite experiments.
           ./ngrok http -subdomain=customdomain 9393
    [] Deploying to cloud host
        [] heroku notes:
    [] Consumer data transfers to other components? Data stores?
        [] Maintain simple text file?
        [] Write to database?
        [X] Sneakers and thumbdrives? 

[] Other concerns outside of the webhook component:
  [] Rule manager: takes user submissions and converts those to PowerTrack rules and adds to stream.
  [] Alarm listener: monitors real-time stream for Tweets of (geo) interest,
  [] Notifier: send DM Notifications to subscribers. 


## Having users share their location.

In order to prototype a geo-aware notification system, knowing subscriber locations of interest is key metadata. 

This system is being deployed on the Twitter platform, which is a unique social media network since it has an emphasis on public communications. At the same time, Twitter offers private communcation with Direct Messages. These private messages enable subscribers to privately share their areas of interest. A key phrase here is "of interest." This notification system does not know the user's *current* and *precise* location, but rather it knows a more general area of interest. These areas of interest are (currently) circles with a 25-mile radius. 

The prototye gives users two options for sharing their location of intertest:

+ Pick from a list of locations. For this prototype is a list of Texas cities.
+ Select location on a map. This map defaults to your device's current location, and is scrollable so you can select any location.

When a user pick from the list, 

answer = user_dm['direct_message_events']['message_create']['message_data']['quick_reply_response']
if answer == 'list'
if answer == 'map'
if answer == 'unsubscribe'

user_id = user_dm['direct_message_events']['message_create']['sender_id']


user_dm['direct_message_events']['message_create']['message_data']['entities']['urls']['expanded_url']
-->  "https://twitter.com/i/location?lat=32.71790004525148&long=-97.32473787097997"


user_dm['direct_message_events']['message_create']['message_data']['attachment']['location']['shared_coordinates']['coordinates']['coordinates'] --> array --> 
['coordinates'][0] --> -97.032########  
['coordinates'][1] --> 32.7179000##### 


## From subscriptions to real-time PowerTrack 





## Example JSON

### User picked 'share location' method:


```
"direct_message_events": [
    {
      "type": "message_create",
      "id": "862053336907894788",
      "created_timestamp": "1494364506352",
      "message_create": {
        "target": {
          "recipient_id": "17200003"
        },
        "sender_id": "944480690",
        "message_data": {
          "text": "Pick area of interest from list",
          "entities": {
            "hashtags": [
              
            ],
            "symbols": [
              
            ],
            "user_mentions": [
              
            ],
            "urls": [
              
            ]
          },
          "quick_reply_response": {
            "type": "options",
            "metadata": "location_list"
          }
        }
      }
    }
  ],
  "users": {
    "17200003": {
      "id": "17200003",
      "created_timestamp": "1225926397000",
      "name": "Think Snow \u2744\ufe0f\u2603\ud83d\udca7\ud83c\udf0e",
      "screen_name": "snowman",
      "location": "Longmont, Colorado",
      "description": "family, travel, music, snow, urban farming, photography, coding, weather, hydrology, early-warning systems. From Minnesota, live in Colorado,",
      "protected": false,
      "verified": false,
      "followers_count": 675,
      "friends_count": 408,
      "statuses_count": 1379,
      "profile_image_url": "http:\/\/pbs.twimg.com\/profile_images\/697445972402540546\/2CYK3PWX_normal.jpg",
      "profile_image_url_https": "https:\/\/pbs.twimg.com\/profile_images\/697445972402540546\/2CYK3PWX_normal.jpg"
    },
    "944480690": {
      "id": "944480690",
      "created_timestamp": "1352750395000",
      "name": "demo account",
      "screen_name": "FloodSocial",
      "location": "Burlington, MA USA",
      "description": "Testing, testing, 1, 2, 3, testing. Used for testing, but also for demoing the Twitter platform... Coming soon?",
      "url": "https:\/\/t.co\/iTHxRCia2w",
      "protected": false,
      "verified": false,
      "followers_count": 29,
      "friends_count": 10,
      "statuses_count": 68,
      "profile_image_url": "http:\/\/pbs.twimg.com\/profile_images\/2880307445\/a6de07ce4053d93d9dd8db5f56f210ec_normal.png",
      "profile_image_url_https": "https:\/\/pbs.twimg.com\/profile_images\/2880307445\/a6de07ce4053d93d9dd8db5f56f210ec_normal.png"
    }
  }
}
```


### User picked area of interest from location list:

```
{
  "direct_message_events": [
    {
      "type": "message_create",
      "id": "862160427215712260",
      "created_timestamp": "1494390038671",
      "message_create": {
        "target": {
          "recipient_id": "17200003"
        },
        "sender_id": "944480690",
        "message_data": {
          "text": "Austin",
          "entities": {
            "hashtags": [
              
            ],
            "symbols": [
              
            ],
            "user_mentions": [
              
            ],
            "urls": [
              
            ]
          },
          "quick_reply_response": {
            "type": "options"
          }
        }
      }
    }
  ],
  "users": {
    "17200003": {
      "id": "17200003",
      "created_timestamp": "1225926397000",
      "name": "Think Snow \u2744\ufe0f\u2603\ud83d\udca7\ud83c\udf0e",
      "screen_name": "snowman",
      "location": "Longmont, Colorado",
      "description": "family, travel, music, snow, urban farming, photography, coding, weather, hydrology, early-warning systems. From Minnesota, live in Colorado,",
      "protected": false,
      "verified": false,
      "followers_count": 675,
      "friends_count": 408,
      "statuses_count": 1380,
      "profile_image_url": "http:\/\/pbs.twimg.com\/profile_images\/697445972402540546\/2CYK3PWX_normal.jpg",
      "profile_image_url_https": "https:\/\/pbs.twimg.com\/profile_images\/697445972402540546\/2CYK3PWX_normal.jpg"
    },
    "944480690": {
      "id": "944480690",
      "created_timestamp": "1352750395000",
      "name": "demo account",
      "screen_name": "FloodSocial",
      "location": "Burlington, MA USA",
      "description": "Testing, testing, 1, 2, 3, testing. Used for testing, but also for demoing the Twitter platform... Coming soon?",
      "url": "https:\/\/t.co\/iTHxRCia2w",
      "protected": false,
      "verified": false,
      "followers_count": 29,
      "friends_count": 10,
      "statuses_count": 68,
      "profile_image_url": "http:\/\/pbs.twimg.com\/profile_images\/2880307445\/a6de07ce4053d93d9dd8db5f56f210ec_normal.png",
      "profile_image_url_https": "https:\/\/pbs.twimg.com\/profile_images\/2880307445\/a6de07ce4053d93d9dd8db5f56f210ec_normal.png"
    }
  }
}


```

### User picked area of interest from map:

```

{
  "direct_message_events": [
    {
      "type": "message_create",
      "id": "862154965623689219",
      "created_timestamp": "1494388736526",
      "message_create": {
        "target": {
          "recipient_id": "17200003"
        },
        "sender_id": "944480690",
        "message_data": {
          "text": " https:\/\/t.co\/JyjKciQmnt",
          "entities": {
            "hashtags": [
              
            ],
            "symbols": [
              
            ],
            "user_mentions": [
              
            ],
            "urls": [
              {
                "url": "https:\/\/t.co\/JyjKciQmnt",
                "expanded_url": "https:\/\/twitter.com\/i\/location?lat=32.71790004525148&long=-97.32473787097997",
                "display_url": "twitter.com\/i\/location?lat\u2026",
                "indices": [
                  1,
                  24
                ]
              }
            ]
          },
          "attachment": {
            "type": "location",
            "location": {
              "type": "shared_coordinate",
              "shared_coordinate": {
                "coordinates": {
                  "type": "Point",
                  "coordinates": [
                    -97.32473787098,
                    32.717900045251
                  ]
                }
              }
            }
          },
          "quick_reply_response": {
            "type": "location",
            "metadata": "not used, useful?"
          }
        }
      }
    }
  ],
  "users": {
    "17200003": {
      "id": "17200003",
      "created_timestamp": "1225926397000",
      "name": "Think Snow \u2744\ufe0f\u2603\ud83d\udca7\ud83c\udf0e",
      "screen_name": "snowman",
      "location": "Longmont, Colorado",
      "description": "family, travel, music, snow, urban farming, photography, coding, weather, hydrology, early-warning systems. From Minnesota, live in Colorado,",
      "protected": false,
      "verified": false,
      "followers_count": 675,
      "friends_count": 408,
      "statuses_count": 1380,
      "profile_image_url": "http:\/\/pbs.twimg.com\/profile_images\/697445972402540546\/2CYK3PWX_normal.jpg",
      "profile_image_url_https": "https:\/\/pbs.twimg.com\/profile_images\/697445972402540546\/2CYK3PWX_normal.jpg"
    },
    "944480690": {
      "id": "944480690",
      "created_timestamp": "1352750395000",
      "name": "demo account",
      "screen_name": "FloodSocial",
      "location": "Burlington, MA USA",
      "description": "Testing, testing, 1, 2, 3, testing. Used for testing, but also for demoing the Twitter platform... Coming soon?",
      "url": "https:\/\/t.co\/iTHxRCia2w",
      "protected": false,
      "verified": false,
      "followers_count": 29,
      "friends_count": 10,
      "statuses_count": 68,
      "profile_image_url": "http:\/\/pbs.twimg.com\/profile_images\/2880307445\/a6de07ce4053d93d9dd8db5f56f210ec_normal.png",
      "profile_image_url_https": "https:\/\/pbs.twimg.com\/profile_images\/2880307445\/a6de07ce4053d93d9dd8db5f56f210ec_normal.png"
    }
  }
}

```


