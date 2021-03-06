require 'net/http'
require 'nokogiri'
require 'uri'
require 'responder_callback'
require 'hipchat'

class CovCukeNotifier < ResponderCallback

	# On failure, send cruise:coverage and cucumber failures to hipchat.
	def after_response(status_hash, responder)
		if responder.activity =~ /fail/i
			build_url = URI.parse(status_hash[:build_url])
			source = Net::HTTP.get(build_url.host, "#{build_url.path}/artifacts/build.log")
			#log = Nokogiri::HTML.parse(source).css('.logfile').to_s

			covout = specs_cov_failures(source)
			cukeout = cucumber_failures(source)
			Hipchat.hip_post("<pre>Specs and Coverage Failures:\n#{covout}</pre>", :color => 'red') unless covout.empty?
			# Cuke output separated by failing steps and failing scenarios.
			cukeout.each { |out| Hipchat.hip_post("<pre>#{out.strip}</pre>", :color => 'red') } unless cukeout.empty?
		end
	end

	# Note: These are shamelessly tailored to our setup. Ideally, this should be more general, but you can always
	# override this with your own easily. Ruby FTW.

	# Return a string of all the specs and coverage failures captured
	# TODO might need to break this up if there are too many failures. Otherwise we might get an exception and it'll just die
	def specs_cov_failures(log)
		log.scan(/rm -r coverage.+?(1\).+?Finished in .+?\n).+(^.+LOC$)/m).flatten.join("\n").strip
	end

	# Returns an array of failures captured
	# A giant string would end up causing Net::HTTP to choke, so we're sending back an array to send in chunks.
	# Might need to do the same for specs_cov_failures, too.
	def cucumber_failures(log)
		log.scan(/(\(::\) failed steps \(::\).+?)(Failing Scenarios:.+?Scenario:[^\n\r]+)\n\n/m).flatten
	end

end
