require_relative 'sftp_provider'
require_relative 'date_tools'
require 'date'
require 'getoptlong'
require_relative 'logging'
require_relative 'ftp_connections'

module Gobi
  include Logging

  @remote_dir = 'gobiord'
  @local_dir = File.expand_path(File.join(__dir__, '../data'))
  opts = GetoptLong.new(
    ['--local_dir', '-o', GetoptLong::REQUIRED_ARGUMENT],
    ['--remote_dir', '-r', GetoptLong::REQUIRED_ARGUMENT]
  )

  opts.each do |opt, arg|
    case opt
    when '--local_dir'
      @local_dir = arg
    when '--remote_dir'
      @remote_dir = arg
    end
  end

  file_date = Time.now.strftime('%m%d')
  retrieve_file = ARGV[0] || "ebook#{file_date}.ord"
  @today_date = Time.now.strftime('%d/%m/%Y')

  CONFIG = FTPConnections.connection

  def self.date_diff_over?(date, days_diff = 10)
    date_diff = DateTools.date_diff(date, @today_date)
    message = "Timestamp of file is #{date_diff} day(s) from todays date. " \
              'May be file from last year so will not download'
    logger.info message if date_diff > days_diff
  end

  def self.process_gobi(conn, retrieve_file)
    return unless (files = conn.get_dir_entries(@remote_dir))

    files.each do |file|
      next unless file.name.eql? retrieve_file

      logger.info "Found file #{retrieve_file} on server going to download"
      date = file.attributes.mtime
      unless date_diff_over?(date)
        conn.download_file("#{@remote_dir}/#{retrieve_file}", "#{@local_dir}/#{retrieve_file}")
      end
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
