# Performs routine functions using Net::SFTP
require 'net/ssh'
require 'net/sftp'
require 'yaml'
require 'erb'
require_relative 'docker'
require_relative 'logging'

# Performs common
class SFTPProvider
  include Logging
  config_path = File.expand_path('../config', __dir__)

  Docker::Secret.setup_environment!
  CONFIG = YAML.safe_load(ERB.new(File.read("#{config_path}/connections.yml")).result)

  # def initialize(site)
  def initialize(host, user, password)
    retries = 0
    logger.info "trying to connect to #{ENV['GOBI_HOST']} ftp server"
    # rubocop:disable Lint/UselessAssignment
    @sftp = Net::SFTP.start(
      host,
      user,
      { password: password, port: 22, append_all_supported_algorithms: true },
      sftp_options = { version: 3 }
    )
    # rubocop:enable Lint/UselessAssignment
    logger.info 'connected'
  rescue StandardError => e
    sleep 10
    retry if (retries += 1) < 4
    logger.info "Could not connect to remote server #{e}. Tried to connect #{retries} time(s)"
  end

  def connection_open?
    return true if defined?(@sftp)
  end

  def download_file(remote_file, local_file)
    @sftp.download!(remote_file, local_file)
    logger.info "Downloaded #{remote_file} to #{local_file}"
  rescue Net::SFTP::StatusException => e
    logger.info "File #{remote_file} not found on remote server #{e}"
  end

  # returns array of name objects for a given directory
  def get_dir_entries(dir)
    @sftp.dir.entries(dir)
  rescue Net::SFTP::StatusException => e
    logger.info "Directory #{dir} not found on remote server #{e}"
  end
end
