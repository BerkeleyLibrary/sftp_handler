#!/usr/bin/env ruby

File.join(File.expand_path('..', __dir__), 'lib').tap do |lib|
  $LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
end

require 'docker'
Docker::Secret.setup_environment!

require 'berkeley_library/sftp_handler'

BerkeleyLibrary::SftpHandler::Cli.start(ARGV)
