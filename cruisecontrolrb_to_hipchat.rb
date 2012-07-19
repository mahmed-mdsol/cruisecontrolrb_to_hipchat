require "sinatra/base"
require 'yaml'
require "cruise_responder"

# TODO: Clean this up and make it a proper MVC web app.
class CruisecontrolrbToHipchat < Sinatra::Base
  
  responder = CruiseResponderTask.new( (ENV['CAPN_CRUISE_LOCALE'] || 'normal').downcase.to_sym )

  # TODO this should be done better
  if ENV['CAPN_CRUISE_CALLBACKS']
    Dir['responder_callbacks/*'].each{|rb| require rb.gsub('.rb', '')}
    # Make new instances of each class
    callbacks = ENV['CAPN_CRUISE_CALLBACKS'].split(/, */).collect{|cls| Kernel.const_get(cls).new } 
    responder.callbacks.concat(callbacks)
  end
  
  scheduler = Rufus::Scheduler.start_new
  scheduler.every("#{ENV["POLLING_INTERVAL"] || 1}m", responder)

  ########################################################################
  # SERVER
  ########################################################################
  
  get "/" do
    "howdy!"
  end

  get "/config/?" do
    "TODO: This page!"
  end

  get "/scores/?" do
    # TODO Extract achievements and scores module to include in all achievements/scores
    require 'responder_callbacks/blamer'
    require 'responder_callbacks/smurf_award'
    if File.exists?(Blamer::BLAME_FILE)
      html = "
      <html>
      <head>
      <title>Scores</title>
      <style type='text/css'>
        table img {
          width: 3em;
          height: 3em;
        }
        table {
          text-align: center;
        }
      </style>
      </head>
      <body>
      <table cellpadding='10px'><tr><th>Committer</th><th>Score</th><th>Achievements</th></tr>"
      scores = YAML::load(File.open(Blamer::BLAME_FILE, 'r'))
      achievements = SmurfAward.read_achievements
      players = (scores.keys + achievements.keys).uniq.sort{|p1, p2| -(scores[p1].to_i <=> scores[p2].to_i)} # Sort by score
      html += players.collect{|player| "<tr><td>#{player}</td><td>#{scores[player].to_i}</td><td>#{achievements[player].keys.sort.join if achievements[player]}</td></tr>"}.join + "</table></body></html>"
      html
    else
      "No scores to show, bruh."
    end
  end
end

