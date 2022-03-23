require_relative 'sftp_provider'
require_relative 'date_tools'
require 'date'
require_relative 'logging'
require_relative 'ftp_connections'

module Gobi
  include Logging

  file_date = Time.now.strftime('%m%d')
  retrieve_file = ARGV[0] || "ebook#{file_date}.ord"
  @today_date = Time.now.strftime('%d/%m/%Y')
  REMOTE_DIR = 'gobiord'.freeze
  DATA_DIR = File.expand_path(File.join(__dir__, '../data'))

  CONFIG = FTPConnections.connection

  def self.date_diff_over?(date, days_diff = 10)
    date_diff = DateTools.date_diff(date, @today_date)
    message = "Timestamp of file is #{date_diff} day(s) from todays date. " \
              'May be file from last year so will not download'
    logger.info message if date_diff > days_diff
  end

  def self.process_gobi(conn, retrieve_file)
    return unless (files = conn.get_dir_entries(REMOTE_DIR))

    files.each do |file|
      next unless file.name.eql? retrieve_file

      logger.info "Found file #{retrieve_file} on server going to download"
      date = file.attributes.mtime
      conn.download_file("#{REMOTE_DIR}/#{retrieve_file}", "#{DATA_DIR}/#{retrieve_file}") unless date_diff_over?(date)
    end
  end

  # Initialize the ftp connection
  conn = SFTPProvider.new(CONFIG['gobi']['host'], CONFIG['gobi']['user'], CONFIG['gobi']['password'])
  if conn.connection_open?
    Gobi.process_gobi(conn, retrieve_file)
  else
    logger.error "Couldn't connect to Gobi ftp server. Exiting"
  end

end
