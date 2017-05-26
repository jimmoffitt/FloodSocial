#!/usr/bin/env python
import time
import datetime
import json
import yaml
from gnippy import PowerTrackClient
import subprocess #calls Tweeting app.
import os

# Define a callback
def callback(activity):

    print(activity) #to standard out.    

    #Parse the things we need: who posted it, when it was posted, what rules/subscribers matched it?  And a link to the Tweet. 
    tweet_hash = json.loads(activity)
    user = tweet_hash['user']['screen_name']
    created_time_str = tweet_hash['created_at']
    tweet_link = ''
    subscribers = tweet_hash['matching_rules']

    #Let's do some trigger-tweet to response-tweet latency.
    time_created = datetime.datetime.strptime(created_time_str,'%a %b %d %H:%M:%S +0000 %Y')
    time_now = datetime.datetime.utcnow()
    seconds = (time_now - time_created).total_seconds()
    
    #subscribers.each do |subscriber|

    
    #Details for calling separate Tweeting app.
    app_to_call = 'ruby'
    send_direct_message_script = '../../../notify/dm/send_direct_message.rb'
    
    message = 'Tweet: ' + tweet_link + '(Responding in ' + "{0:.2f}".format(seconds) + ' seconds)'
    
    #For DM
    tweet_args = [user, message]
    
    #For Tweet
    #tweet_args = '@' + user + ' thanks for Tweeting! Responding (in ' + "{0:.2f}".format(seconds) + ' seconds) from a Raspberry Pi 3 running a Ruby-based Tweeting app.'

    result = subprocess.check_output([app_to_call, send_direct_message_script, tweet_args], cwd='./')
 
#------------------------------------------------   
# Create the client

if os.path.isfile('./config_private.yaml'):
    settings = yaml.load('./config_private.yaml')
    account_name = settings['power_track']['account_name']
    user_name = settings['power_track']['user_name']
    password = settings['power_track']['password']
    label = settings['power_track']['label']   
else:    
    account_name = os.environ['GNIP_USER_NAME']
    password = os.environ['GNIP_PASSWORD']
    account_name = os.environ['GNIP_ACCOUNT_NAME']
    label = os.environ['GNIP_LABEL']
    
my_url = 'https://gnip-stream.twitter.com/stream/powertrack/accounts/' + label + '/publishers/twitter/' + label + '.json'

client = PowerTrackClient(callback, url=my_url, auth=(user_name, password))
client.connect()

while True:
  x = 1  
