This is a little Sinatra app notifies Hipchat of any changes in the build status on your CruiseControl.rb install (with a piratey flair!)

Adapted from andrewpbrett/cruisecontrolrb_to_hipchat and customized a bit for my own use.

## Heroku-ready! 

Just follow these steps:

1. Grab a copy of the source

        git clone git@github.com:andrewpbrett/cruisecontrolrb-to-hipchat.git

2. Create a Heroku app

        heroku create myapp

3. Required configuration
				
				heroku config:add HIPCHAT_AUTH_TOKEN=your_auth_token
				heroku config:add HIPCHAT_ROOM_ID=your_room_id
				heroku config:add CC_URL=your_cruise_control_url

4. Optional configuration:

				Basic auth for your CruiseControlrb install (recommended):
				
				heroku config:add CC_USERNAME=your_username
				heroku config:add CC_PASSWORD=your_password
				
				heroku config:add POLLING_INTERVAL							 # polling interval in minutes. defaults to 1 minute.
				heroku config:add HIPCHAT_FROM=cruise-control    # who the messages are "from" in hipchat. defaults to 'cruise-control'		

5. Deploy to Heroku

        git push heroku master

6. Set up something to ping your app regularly in order to [prevent it from idling](http://stackoverflow.com/questions/5480337/easy-way-to-prevent-heroku-idling). The New Relic add-on seems to do the trick, but so does a cron job, pingdom, etc., etc., etc. ...

7. Have a beer while you wait for your first notification in Hipchat.

## Without Heroku

The run.rb script can be used if you're not using heroku (because I'm not (yet)). At the bare minimum, you need the following environment variables available when you run the script:

```
HIPCHAT_AUTH_TOKEN
HIPCHAT_FROM
HIPCHAT_ROOM_ID

CC_URL # CruiseControl URL

CC_USERNAME (if needed)
CC_PASSWORD (if needed)
```

I've been using a conf.rb file to set all these options before running the script (eventually, I'll stop being lazy and include proper command line arguments)

```ruby
# ./conf.rb

# Hipchat Envs
ENV['HIPCHAT_AUTH_TOKEN'] = 'myhipchatauthtoken'
ENV['HIPCHAT_FROM'] = "Cap'n Cruise"
ENV['HIPCHAT_ROOM_ID'] = "Gilligan's Island"

# Cruise watcher envs
ENV['POLLING_INTERVAL'] = '1' #Every minute
ENV['CC_URL'] = 'http://cruise-control.myserver.com'
ENV["CC_USERNAME"] = "" 
ENV["CC_PASSWORD"] = ""

# CAPN_CRUISE Stuff!
ENV['CAPN_CRUISE_LOCALE'] = 'pirate' # Right now, only pirate and normal are available
ENV['CAPN_CRUISE_CALLBACKS'] = "Blamer, CovCukeNotifier" # Note that these'll be loaded and run in order

require 'run' # Run it!
# Alternatively, you can fork and forget:
# Process.detach(fork{ require 'run' })

```

To actually run it...

```
bundle install
bundle exec ruby conf.rb
```

That's all, folks! :D
