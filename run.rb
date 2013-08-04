# Silly little hack to use the config.ru file and start the app without needing rackup
ENV['CAPN_CRUISE_PORT'] ||= "4567"
def run(cls)
  cls.run!(:port => ENV['CAPN_CRUISE_PORT'])
  File.open('capn.pid', 'w'){|f| f.puts(Process.pid)}
end

$:<< '.'
load './config.ru'
