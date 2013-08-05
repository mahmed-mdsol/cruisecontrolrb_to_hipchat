require 'uri'
require 'responder_callback'
require 'hipchat'

# Callback class that posts the code metrics of a successful build to hipchat
class CodeMetricsNotifier < ResponderCallback

	# On successful cruise build, send code metrics link to hipchat.
	def after_response(status_hash, responder)
		if responder.activity =~ /Success/i
      code_metrics_url = "#{status_hash[:build_url]}/artifacts/code_metrics/html/index.html"
      Hipchat.hip_post("<a href='#{code_metrics_url}'>Code Metrics for the build</a>", :color => 'green')
		end
	end

end
