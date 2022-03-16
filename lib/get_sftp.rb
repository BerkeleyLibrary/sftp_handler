# Performs routine functions using Net::SFTP
class GetSFTP
  require 'net/ssh'
  require 'net/sftp'
  require 'yaml'
  require_relative 'docker'
  require_relative 'logging'
  include Logging
  config_path = File.expand_path('../config', __dir__)

  #config_path = '../config'
  Docker::Secret.setup_environment!
  CONFIG = YAML.load_file(File.join(config_path, 'connections.yml'))

  def initialize(site)
    retries = 0
    logger.info "trying to connect to #{ENV['GOBI_HOST']} ftp server"
    # @sftp = Net::SFTP.start(
    #    CONFIG[site]['host'],
    #    CONFIG[site]['user'],
    #    { password: CONFIG[site]['password'], port: 22, append_all_supported_algorithms: true },
    #    sftp_options = { :version => 3 }
    #  )

    # rubocop:disable Lint/UselessAssignment
    @sftp = Net::SFTP.start(
      ENV['GOBI_HOST'],
      ENV['GOBI_USER'],
      { password: ENV['GOBI_PASS'], port: 22, append_all_supported_algorithms: true },
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
    return nil
  end
end
