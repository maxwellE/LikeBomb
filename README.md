LikeBomb
========
By: Maxwell Elliott <elliott.432@buckeyemail.osu.edu>

A nifty Ruby script that when given a valid FaceBook Graph API Key
will like and/or leave a comment on every one of 
your friend's statuses and/or photos!  At any rate this gem is a cool
look at the Facebook Graph API and it's abilities.
Getting Started
-----------------
**Step 1: Install gem**

    $ gem install like_bomb
**Step 2: Get a valid Graph API key**

Goto: <http://developers.facebook.com/tools/explorer> and click 'Get Access Token'.
  You will need to log into Facebook to do this.

Make sure your permissions look similar to the images below! If you do not have these
exact permissions the application may not work! 

**Critical** permissions include:

* publish_stream
* friends_status
* friends_photos
* user_likes
* publish_actions
* read_stream
* export_stream

**My Permissions, gem will work flawlessly with these settings:**

![User Data Permissions](http://i47.tinypic.com/fvi448.png "User Data Permissions")

![Friend Data Permissions](http://i45.tinypic.com/2yvmkk5.png "Friend Data Permissions")

![Extended Permissions](http://i49.tinypic.com/24xi97d.png "Extended Permissions")

**NOTE:  Your access token may expire after a set amount of time which is variable
by Facebook.**  
If you are getting exceptions in your code it is most likey due to
the fact that your access token is expired!  To renew your access code simple 
generate another at <http://developers.facebook.com/tools/explorer> .  I am looking
into automating this renewal and will accept pull requests for this feature

**Step 3: Lock 'n Load**

With your valid API key in hand you are ready to do some damage!

**Post Likes on statuses**

```ruby
# This will go to your first friend from the Graph API and will like
# all of his/her statuses
lb = LikeBomb.new("<VALID_KEY>")
friend_hash = lb.get_friends 
unliked_statuses = lb.get_statuses(friend_hash.first)[:not_liked] # Get not liked statuses
lb.post_likes(unliked_statuses)
```

**Post 'Cool!'s on photos**

```ruby
# This will go to your last friend from the Graph API and will comment
# 'Cool!'' on all of his/her photos
lb = LikeBomb.new("<VALID_KEY>")
friend_hash = lb.get_friends 
uncooled_photos = lb.get_photos(friend_hash.last)[:not_cooled] 
lb.post_cools(uncooled_photos)
```

## License

*(This project is released under the MIT license*

Copyright (c) 2012 Maxwell Elliott

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
