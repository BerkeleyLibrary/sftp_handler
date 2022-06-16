require 'berkeley_library/sftp_handler/downloader/base'
require 'net/sftp'
require 'pathname'

module BerkeleyLibrary
  module SftpHandler
    module Downloader
      # Downloads the latest lbnl_people_yyyymmdd.zip patron file.
      #
      # LBNL seems to populate this every Monday, so by default the class looks for the file
      # that would've been added on the most recent Monday. If today is Monday, it uses today's
      # date, otherwise it walks back to the previous one.
      class Lbnl < Base
        def download!(filename: nil, local_dir: '/opt/app/data')
          filename ||= default_filename
          remote_path = Pathname.new(filename)
          local_path = Pathname.new(local_dir) + filename
          assert_not_exists! local_path

          connect do |sftp|
            sftp.download!(remote_path, local_path)
          rescue Net::SFTP::StatusException
            puts "Remote file #{remote_path} does not exist"
          end
        end

        def default_host
          'ncc-1701.lbl.gov'
        end

        def default_username
          'ucblib'
        end

        def default_filename
          @default_filename ||= "lbnl_people_#{most_recent_monday.strftime('%Y%m%d')}.zip"
        end

        def most_recent_monday
          today = Date.today
          days_from_monday = (today.wday + 6) % 7
          today - days_from_monday
        end
      end
    end
  end
end
