require 'yaml'
require 'erb'
require_relative 'docker'
require_relative 'logging'

module FTPConnections
  include Logging
  Docker::Secret.setup_environment!

  def self.connection
    logger.info 'Getting ftp configurations'
    config_path = File.expand_path('../config', __dir__)
    YAML.safe_load(ERB.new(File.read("#{config_path}/connections.yml")).result)
  end

end
