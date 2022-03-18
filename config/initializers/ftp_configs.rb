require 'erb'
require 'yaml'
require_relative '../../lib/docker'

module FtpConfigs
  def load_ftp_configs
    config_path = File.expand_path('..', __dir__)
    Docker::Secret.setup_environment!
    FTP_CONFIGS = YAML.load(ERB.new(File.read("#{config_path}/connections.yml")).result)
  end
end
