require 'net/http'
require 'nokogiri'
require 'yaml'
require 'responder_callback'
require 'hipchat'

# TODO: A general achievements class with custom achievement subclasses
class SmurfAward < ResponderCallback
	ACHIEVEMENTS_FILE = 'achievements.yml'
	SMURF_ACHIEVEMENT = '<img src="/images/smurf_icon.gif" alt="Smurf Cruise - For contributing to an all-blue cruise" title="Smurf Cruise - For contributing to an all-blue cruise" />'

	def after_response(status_hash, responder)
		if status_hash[:activity] =~ /Success/i
			base_url = responder.ccrb.base_url.gsub(/ *https?:\/\//, '').gsub(/\/ *$/, '')
			source = Net::HTTP.get(base_url, '/')
			smurfed = Nokogiri::HTML.parse(source).css('.failed').length == 0
			if smurfed
				committers = source.scan(/committed by (.+?) &lt;/).flatten.uniq # get the committers who are a part of the smurf cruise!
				achievements = read_achievements

				new_smurfs = []
				committers.each do |committer|
					committer = committer.strip
					achievements[committer] ||= {}
					new_smurfs << committer unless achievements[committer][SMURF_ACHIEVEMENT]
					achievements[committer][SMURF_ACHIEVEMENT] = true
				end
				write_achievements(achievements)
				Hipchat.hip_post("<b>Achievement Unlocked: <i>Smurf Cruise!</i></b><br>Achievement awarded to the following committers: #{new_smurfs.join(', ')}!", :color => 'purple') unless new_smurfs.empty?
			end
		end
	end
	
	# TODO Extract to an achievements module to include in all achievements

	def read_achievements
		self.class.read_achievements
	end

	def write_achievements(achievements)
		self.class.write_achievements(achievements)
	end

	def self.read_achievements
		if File.exists?(ACHIEVEMENTS_FILE)
			return YAML::load(File.open(ACHIEVEMENTS_FILE, 'r'))
		else
			write_achievements({})
			return {}
		end
	end

	def self.write_achievements(achievements)
		File.open(ACHIEVEMENTS_FILE, 'w'){|f| YAML::dump(achievements, f)}
	end

end