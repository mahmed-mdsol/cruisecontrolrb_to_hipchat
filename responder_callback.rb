
# An empty superclass defining the hooks that subclasses can implement
class ResponderCallback
  
  # TODO Refactor this
  SCORES_URL = "http://#{ENV['CAPN_CRUISE_HOST'] || 'localhost'}:#{ENV['CAPN_CRUISE_PORT']}/scores"
  
  # Callback for before the responder's response is sent 
  def before_response(status_hash, responder)
  end

  # Callback for after the responder's response is sent.
  def after_response(status_hash, responder)
  end
end
