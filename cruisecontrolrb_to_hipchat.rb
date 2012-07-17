require "sinatra/base"
require 'yaml'
require "./cruise_responder"

class CruisecontrolrbToHipchat < Sinatra::Base
    
  attr_accessor :status
  attr_accessor :activity
  
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
  
  get "/" do
    "howdy!"
  end

  get "/config" do
    "TODO: This page!"
  end

  get "/scores" do
    require 'responder_callbacks/blamer'
    if File.exists?(Blamer::BLAME_FILE)
      html = "<table><tr><th>Committer</th><th>Score</th></tr>"
      scores = YAML::load(File.open(Blamer::BLAME_FILE, 'r'))
      players = scores.keys.sort
      html += players.collect{|player| "<tr><td>#{player}</td><td>#{scores[player]}</td></tr>"}.join + "</table>"
      html
    else
      "No scores to show, bruh."
    end
  end
end

