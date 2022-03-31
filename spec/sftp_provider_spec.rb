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
      expect(@sftp).to receive(:dir).and_return(@dir)
    end

    it 'makes sure sftp mock can call dir method' do
      @sftp.dir
    end

    it 'returns an array of a directories contents' do
      mock_result = %w[one two]
      allow(@dir).to receive(:entries).with('test_dir').and_return(mock_result)
      expect(SFTPProvider.new('host', 'user', 'password').get_dir_entries('test_dir')).to eq(mock_result)
    end

  end

  describe 'download_files' do
    it 'downloads a remote file to a local file' do
      expect(@sftp).to receive(:download!).with('remote_file', 'local_file')
      SFTPProvider.new('host', 'user', 'password').download_file('remote_file', 'local_file')
    end
  end

end
