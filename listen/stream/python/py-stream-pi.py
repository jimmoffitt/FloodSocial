#!/usr/bin/env python
import time
import datetime
import json
import yaml
from gnippy import PowerTrackClient
import subprocess #calls Tweeting app.

# Define a callback
def callback(activity):

    print(activity) #to standard out.    

    tweet_hash = json.loads(activity)
    user = tweet_hash['user']['screen_name']
    subscribers = tweet_hash['matching_rules']

    #subscribers.each do |subscriber|

    #Let's do some trigger-tweet to response-tweet latency.
    created_time_str = tweet_hash['created_at']
    time_created = datetime.datetime.strptime(created_time_str,'%a %b %d %H:%M:%S +0000 %Y')
    time_now = datetime.datetime.utcnow()
    seconds = (time_now - time_created).total_seconds()
    
    #Details for calling separate Tweeting app.
    app_to_call = 'ruby'
    send_direct_message_script = 'twitter_post.rb'
    tweet_args = '@' + user + ' thanks for Tweeting! Responding (in ' + "{0:.2f}".format(seconds) + ' seconds) from a Raspberry Pi 3 running a Ruby-based Tweeting app.' 

    result = subprocess.check_output([app_to_call, post_tweet_script, tweet_args], cwd='./')
    
# Create the client
client = PowerTrackClient(callback, url="https://my.gnip.stream.json", auth=("me@there.com", "mYPaSsWoRd"))
client.connect()

while True:
  x = 1  
