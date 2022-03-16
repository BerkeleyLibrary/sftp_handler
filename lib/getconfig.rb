require 'yaml'

site = 'gobi'
CONFIG_PATH="../config"
config = YAML.load_file(File.join(CONFIG_PATH,'connections.yml'))
puts config[site]['host']
