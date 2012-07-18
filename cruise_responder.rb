require 'yaml'
require 'hipchat'
require 'cruisecontrolrb'

class CruiseResponderTask
  attr_accessor :ccrb, :config, :locale, :activity, :status
  attr_reader :callbacks

  BUILDING_STATUS = "Building"
  RESPONSES_FILENAME = 'responses.yml'
  DEFAULT_RESPONSES = {
    :build_responses => {
      :normal => {
        :responses => {
          :building => "CruiseControl has started a <a href='%s'>build</a>.",
          :success => "Current build status: <a href='%s'>Success</a>",
          :failed => "Current build status: <a href='%s'>Failed</a>"
        },
        :colors => {
          :building => 'yellow',
          :success => 'green',
          :failed => 'red'
        }
      },

      :pirate => {
        :responses => {
          :building => "Ahoy! Set sail fer <a href='%s'>a new expedition</a>, ye lily-livered bilgerats!",
          :success => "We be sailin' on <a href='%s'>a sea o' blue</a>, mateys!",
          :failed => "Aye, <a href='%s'>some scurvy knaves</a> be walkin' the plank."
        },
        :colors => {
          :building => 'yellow',
          :success => 'green',
          :failed => 'red'
        }
      }
    }
  }

  # Initialize the responder, optionally with a response locale
  def initialize(response_locale=:normal)
    self.ccrb = Cruisecontrolrb.new(ENV["CC_URL"], ENV["CC_USERNAME"] || "", ENV["CC_PASSWORD"] || "")
    unless File.exists?(RESPONSES_FILENAME)
      # If we don't have a responses.yml, use the defaults.
      File.open(RESPONSES_FILENAME, 'w') do |f|
        YAML::dump(DEFAULT_RESPONSES, f)
      end
      self.config = DEFAULT_RESPONSES.dup
    else
      # We have a responses file, use the responses in there.
      reload_responses
    end
    self.locale = response_locale.to_sym
    @callbacks ||= []
  end

  # Set the responses to the responses in the responses.yml file
  def reload_responses
    self.config = YAML::load(File.open(RESPONSES_FILENAME))
  end

  # Localized options
  def localized
    config[:build_responses][locale] || DEFAULT_RESPONSES[:build_responses][:normal]
  end

  # Retrieve the responses from the responses hash for the given "locale"
  def responses
    localized[:responses]
  end

  # Retrieve the colors for the given localization
  def colors
    localized[:colors]
  end

  def each_callback
    callbacks.each do |callback|
      begin
        yield(callback)
      rescue Exception => e
        STDERR.puts "#{callback.inspect} raised #{e}"
      end
    end
  end


  # The task to perform every interval
  def call(job)
    # TODO support multiple projects
    status_hash = ccrb.fetch
    unless status_hash.empty?
      new_activity = status_hash[:activity]
      build_label = status_hash[:lastBuildLabel]

      # TODO this feels like a hack
      # It seems that the activity can stay the same between builds so check for a build label change to see if you missed the switch.
      # change will be Success/Failed if the build label changed, but if the build label stays the same, chances are we're building (new_activity)
      change = 
        if @last_build != build_label
          status_hash[:lastBuildStatus]
        elsif @activity != new_activity
          new_activity
        else
          nil
        end
      
      if change
        # There was a change!
        # Notify the hipsters!

        # Interpolate the build_url into the response and the lastBuildStatus if needed
        status_sym = change.downcase.strip.to_sym
        message = (responses[status_sym] || '') % [status_hash[:build_url], status_hash[:lastBuildStatus]]
        unless message.empty?
          # Callbacks
          each_callback{|callback| callback.before_response(status_hash, self)}

          Hipchat.hip_post(message, :color => colors[status_sym])

          @activity = change
          @last_build = build_label
          # Call callbacks
          each_callback{|callback| callback.after_response(status_hash, self)}
        end
      end
    end
  end

end
