
# An empty superclass defining the hooks that subclasses can implement
class ResponderCallback
  # Callback for before the responder's response is sent 
  def before_response(status_hash, responder)
  end

  # Callback for after the responder's response is sent.
  def after_response(status_hash, responder)
  end
end
