# FloodSocial

Code for an example Twitter notification system based on subscribers sharing locations of interest.

+ /enroll - the _Enroller_ - Twitter Account Activity Webhook consumer, subscribers share location privately.
+ /listen - the _Listener_ - Filters Twitter firehose for Tweets of interest, Tweets within areas of interest. 
  + Real-time PowerTrack stream consumer   
  + PowerTrack Rules Manager
+ /notify - the _Notifier_ - sending notification Direct Messages with latest Twitter DM API.
