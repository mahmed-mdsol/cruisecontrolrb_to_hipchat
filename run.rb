# Silly little hack to use the config.ru file without needing rackup
ENV['CAPN_CRUISE_PORT'] ||= "4567"
def run(cls)
	cls.run! :port => ENV['CAPN_CRUISE_PORT']
end

load './config.ru'
