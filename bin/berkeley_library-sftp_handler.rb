#!/usr/bin/env ruby

File.join(File.expand_path('..', __dir__), 'lib').tap do |lib|
  $LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
end

require 'berkeley_library/docker'
BerkeleyLibrary::Docker::Secret.load_secrets!

require 'berkeley_library/sftp_handler'

BerkeleyLibrary::SftpHandler::Cli.start(ARGV)
