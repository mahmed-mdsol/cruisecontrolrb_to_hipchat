require 'httparty'
require 'cgi'

class Hipchat
  include HTTParty

  class << self
    # Defaults to use if options aren't provided
    # Most of these are hipchat API defaults
    DEFAULTS = {
      :auth_token => ENV['HIPCHAT_AUTH_TOKEN'],
      :room_id => ENV['HIPCHAT_ROOM_ID'],
      :from => ENV['HIPCHAT_FROM'] || 'Cruise Control',
      :message_format => 'html',
      :notify => '1', # default is 0, but I like notifications
      :color => 'yellow',
      :format => 'json'
    }

    def hip_post(message, options = {})
      self.post("https://api.hipchat.com/v1/rooms/message?" + query_parameters(options))
    end

    private

    # Turn the hash into a query string
    def query_parameters(options = {})
      # Keep only accepted parameters and overwrite defaults if provided
      options = DEFAULTS.merge(options.reject{|k, v| !DEFAULTS.include?(k)})
      # Join the k=v pairs with & to make a query string.
      options.collect{|key, value| "#{CGI.escape(key.to_s)}=#{CGI.escape(value.to_s)}"}.join("&")
    end
  end

end
