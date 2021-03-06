# FloodSocial

Code for an example Twitter notification system based on subscribers sharing locations of interest. When those areas match on geo-tagged Tweets of interest, a Direct Message is sent to the subscriber.

+ /enroll - the _Enroller_ - Twitter Account Activity Webhook consumer, subscribers share location privately.
  + PowerTrack Rules Manager - Creates and manages subscriber-specific PowerTrack filters. 
+ /tweet_alert: 
  + _Streaming Tweets of interest_ - Filters Twitter firehose for (geo-tagged) Tweets within areas of interest. 
    + Real-time PowerTrack stream consumer - Receives Tweets within a few seconds of being posted.  
  + _Notifier_ - sending notification Direct Messages with latest Twitter DM API.

## Welcome Message

![](https://raw.githubusercontent.com/jimmoffitt/FloodSocial/master/imgs/options.png)

## Enroll by sharing a location, from list or with map

![](https://raw.githubusercontent.com/jimmoffitt/FloodSocial/master/imgs/add_area.png)

## Sharing a point from a map

![](https://raw.githubusercontent.com/jimmoffitt/FloodSocial/master/imgs/area_map.png)

## Listing areas of interest

![](https://raw.githubusercontent.com/jimmoffitt/FloodSocial/master/imgs/list_areas.png)

