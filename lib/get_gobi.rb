require_relative 'sftp_provider'
require_relative 'date_tools'
require 'date'
require_relative 'logging'
include Logging

file_date = Time.now.strftime('%m%d')
retrieve_file = "ebook#{file_date}.ord"
@today_date = Time.now.strftime('%d/%m/%Y')
REMOTE_DIR = 'gobiord'
DATA_DIR = File.expand_path(File.join(__dir__, '../data')) 
#retrieve_file = 'ebook0309.ord'

def process_gobi(conn, retrieve_file)
  return unless files = conn.get_dir_entries(REMOTE_DIR)

  files.each do |file|
    next unless file.name.eql? retrieve_file

    logger.info "Found file #{retrieve_file} on server going to download"
    date = file.attributes.mtime
    conn.download_file("#{REMOTE_DIR}/#{retrieve_file}", "#{DATA_DIR}/#{retrieve_file}") unless DateTools.date_diff(date, @today_date) > 10
  end
end

# Initialize the ftp connection
conn = SFTPProvider.new('gobi')
if conn.connection_open?
  process_gobi(conn, retrieve_file)
else
  logger.error "Coulnd't connect to Gobi ftp server. Exiting"
end
