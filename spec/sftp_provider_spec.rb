# spec/sftp_provider_spec.rb
require 'sftp_provider'
require 'spec_helper'

describe SFTPProvider do

  before do
    @sftp = instance_double(Net::SFTP::Session)
    pass = { password: 'password', port: 22, append_all_supported_algorithms: true }

    # rubocop:disable Lint/UselessAssignment
    allow(Net::SFTP).to receive(:start).with('host', 'user', pass, sftp_options = { version: 3 }).and_return(@sftp)
    # rubocop:enable Lint/UselessAssignment

  end

  describe 'get_dir_entries' do
    before do
      @dir = instance_double(Net::SFTP::Operations::Dir)
    end

    it 'makes sure sftp mock can call dir method' do
      expect(@sftp).to receive(:dir).and_return(@dir)
      @sftp.dir
    end
  end

  describe 'download_files' do
    it 'downloads a remote file to a local file' do
      expect(@sftp).to receive(:download!).with('remote_file', 'local_file')
      SFTPProvider.new('host', 'user', 'password').download_file('remote_file', 'local_file')
    end
  end

end
