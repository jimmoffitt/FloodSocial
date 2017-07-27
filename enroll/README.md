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

![](https://github.com/jimmoffitt/FloodSocial/blob/master/imgs/welcome_message.png)

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




==========================================

## Getting started 

As outlined [HERE](https://dev.twitter.com/webhooks/getting-started), here are the steps to take to set up access to and the 'plumbing' of the Account Activity API"


Configuring Twitter Webhooks

+ Create a Twitter Application, and have it enabled with the Account Activity API. For now, you'll need to apply for Account Activity API access [HERE](https://gnipinc.formstack.com/forms/account_activity_api_configuration_request_form).
+ Subscribe your consumer web app using the Account Activity API
+ Create a default Welcome Message 

Webhook Setup

CR

Validate setup


# Next Steps


+ Twitter Webhook APIs https://dev.twitter.com/webhooks
+ Account Activity API documentation https://dev.twitter.com/webhooks/account-activity
+ Direct Message API methods: https://dev.twitter.com/rest/direct-messages

To help you put all that information together, check out our [Twitter Direct Message API Playbook].

==========================================

As a developer, the next steps you'll take:

+ Developing Webhook Consumer
+ Stand-up a web application that will be your webhook consumer 
+ Implement a consumer Challenge Response Check (CRC) method
+ Implement a consumer webhook event manager




