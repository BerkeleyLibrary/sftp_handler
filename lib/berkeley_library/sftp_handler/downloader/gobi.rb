require 'berkeley_library/sftp_handler/downloader/base'
require 'chronic'
require 'net/sftp'
require 'pathname'

module BerkeleyLibrary
  module SftpHandler
    module Downloader
      class Gobi < Base
        def download!(filename: nil, local_dir: '/opt/app/data', modified_after: '10 days ago')
          filename ||= default_filename
          remote_path = Pathname.new('/gobiord') + filename
          local_path = Pathname.new(local_dir) + filename
          # @todo Gobi files are timestamped with only month and day, so we might run into collisions
          #       starting next year unless they clear files off their server.
          assert_not_exists! local_path

          connect do |sftp|
            if modified_after?(sftp, remote_path, modified_after)
              puts "Downloading #{remote_path} to #{local_path}"
              sftp.download!(remote_path.to_s, local_path.to_s)
            end
          rescue Net::SFTP::StatusException
            puts "Remote file #{remote_path} does not exist"
          end
        end

        def modified_after?(sftp, remote_path, modified_after)
          mtime = Time.at(sftp.stat!(remote_path).mtime).to_datetime
          cutoff = Chronic.parse(modified_after).to_datetime
          (mtime >= cutoff).tap do |is_new_enough|
            puts "Skipping file because it is older (#{mtime}) than the cutoff date (#{cutoff})" \
              unless is_new_enough
          end
        end

        def default_filename
          "ebook#{Time.now.strftime('%m%d')}.ord"
        end

        def default_host
          'ftp.ybp.com'
        end

        def default_username
          'berkeley'
        end

        def ssh_options
          super.tap do |opts|
            # @note As of 04/28/22, Gobi's server only supports outdated Diffie-Hellman
            #       key exchange algorithms, which you local sftp client will probably (and
            #       correctly) refuse. If you want to test manually, then for now you must
            #       explicitly allow the old algorithm by passing the following option to your
            #       sftp client: `-oKexAlgorithms=+diffie-hellman-group1-sha1`.
            opts[:append_all_supported_algorithms] = true
          end
        end
      end
    end
  end
end
