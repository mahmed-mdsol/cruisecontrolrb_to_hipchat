require 'httparty'
require 'nokogiri'
require 'uri'

class Cruisecontrolrb
  include HTTParty

  attr_accessor :base_url
  
  def initialize(base_url, username = nil, password = nil)
    @auth = { :username => username, :password => password }
    @base_url = base_url
  end
  
  # TODO support multiple projects
  def fetch
    options = { :basic_auth => @auth }
    noko = Nokogiri::XML(self.class.get("#{@base_url}/XmlStatusReport.aspx", options).parsed_response)
    project_node = noko.search("Project").first
    return {} unless project_node

    status_hash = { 
      :lastBuildStatus => project_node.attributes["lastBuildStatus"].value,
      :webUrl => project_node.attributes["webUrl"].value,
      :lastBuildLabel => project_node.attributes["lastBuildLabel"].value,
      :activity => project_node.attributes["activity"].value
    }

    # Make sure webUrl uses base_url. The response from cruise may use localhost instead of base_url, so use :url over :webUrl
    # Also, you want to go to */builds/* instead of */projects/*
    # I'm keeping webUrl in the status_hash so that it correctly represents the returned response from the server.
    status_hash[:build_url] = "#{base_url}/#{URI.parse(status_hash[:webUrl]).path.gsub('projects', 'builds')}"
    status_hash
  end
  
end