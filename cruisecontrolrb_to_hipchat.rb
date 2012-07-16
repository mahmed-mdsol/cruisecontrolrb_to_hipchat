require "sinatra/base"
require "./cruise_responder"

class CruisecontrolrbToHipchat < Sinatra::Base
    
  attr_accessor :status
  attr_accessor :activity
  
  responder = CruiseResponderTask.new( (ENV['CAPN_CRUISE_LOCALE'] || 'normal').downcase.to_sym )
  
  scheduler = Rufus::Scheduler.start_new
  scheduler.every("#{ENV["POLLING_INTERVAL"] || 1}m", responder)
  
  get "/" do
    "howdy!"
  end
end

