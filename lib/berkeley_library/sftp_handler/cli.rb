require 'berkeley_library/sftp_handler/downloader/gobi'
require 'berkeley_library/sftp_handler/downloader/lbnl'
require 'thor'

module BerkeleyLibrary
  module SftpHandler
    class Cli < Thor
      desc 'gobi', 'Fetch a Gobi order file'
      option :filename,
             desc: "Name of the file to download. Defaults to today's gobi order file."
      option :local_dir,
             desc: 'Local directory to which to download the file.',
             default: '/opt/app/data'
      option :modified_after,
             desc: 'Only download the file if it was modified/created after this date. ' \
                   'Parsed by the Chronic gem (so something like "5 hours ago" is valid).',
             default: '10 days ago'
      def gobi
        gobi = BerkeleyLibrary::SftpHandler::Downloader::Gobi.new
        gobi.download!(**options.transform_keys(&:to_sym))
      end

      desc 'lbnl', 'Fetch an LBNL patrons file'
      option :filename,
             desc: 'Name of the file to download. Defaults to the name of the patron file ' \
                   'uploaded on the most recent Monday.'
      option :local_dir,
             desc: 'Local directory to which to download the file',
             default: '/opt/app/data'
      def lbnl
        lbnl = BerkeleyLibrary::SftpHandler::Downloader::Lbnl.new
        lbnl.download!(**options.transform_keys(&:to_sym))
      end
    end
  end
end
