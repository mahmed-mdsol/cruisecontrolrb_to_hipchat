require 'net/http'
require 'nokogiri'
require 'uri'
require 'yaml'
require 'responder_callback'
require 'hipchat'

#TODO Eventually rename this as Scorer
class Blamer < ResponderCallback

	BLAME_FILE = './blames.yml'

	def after_response(status_hash, responder)
		case responder.activity
		when /Success/i
			plus_or_minus = "+"
			color = 'green'
		when /Fail/i
			plus_or_minus = "-"
			color = 'red'
		else
			plus_or_minus = nil
		end
		if plus_or_minus
			build_url = URI.parse(status_hash[:build_url])
			source = Net::HTTP.get(build_url.host, build_url.path)
			the_committers = committers(source)
			# Send the committers as @Mentions 
			mentioned_committers = the_committers.join(', ') #the_committers.collect{|c| "@#{c.gsub(' ', '')}"}.join(', ')
			unless mentioned_committers.empty?
				Hipchat.hip_post("<a href='#{SCORES_URL}'>#{plus_or_minus}1</a> to #{mentioned_committers}", :color => color)
				update_scores(the_committers, plus_or_minus == '+' ? 1 : -1)
			end
		end
	end

	def update_scores(the_committers, add_on)
		scores = File.exists?(BLAME_FILE) ? YAML::load(File.open(BLAME_FILE)) : {}
		the_committers.each{|committer| scores[committer] = scores[committer].to_i + add_on}
		File.open(BLAME_FILE, 'w'){ |f| YAML::dump(scores, f) }
	end

	def committers(src)
		changes = Nokogiri::HTML.parse(src).css('#build_changeset .terminal_output').to_s
		committers = changes.scan(/committed by (.+) *&lt;/).flatten.collect(&:strip).uniq
	end

end