# spec/sftp_provider_spec.rb
require 'sftp_provider'
require 'spec_helper'


describe SFTPProvider do 
  let(:sftp_config) { {:append_all_supported_algorithms=>true, :password=>"pass", :port=>22} }
  #let(:sftp_config) { {password: 'pass', port: 22, append_all_supported_algorithms: true} }
  let(:dir_double) { double(:dir, entries: ['file-one.txt', 'file-two.txt']) }
  let(:sftp_double) { double(:sftp, download!: true, dir: dir_double) }
  let(:ssh_double) { double(:ssh, sftp: sftp_double) }
  let(:local_file) { 'some-local-file.txt' }
  let(:remote_file) { 'some-remote-file.txt' }
  subject { SFTPProvider.new('host', 'user', 'pass') }

  def stub_connection_and_ensure(message, input_file, output_file)
    expect(Net::SSH).to receive(:start).with('host', 'user', sftp_config).and_yield(ssh_double)
    expect(sftp_double).to receive(message).with(input_file, output_file)
  end

  describe 'download_file' do
    it 'downloads a remote file to a local file via ssh' do
      stub_connection_and_ensure(:download!, remote_file, local_file)
      subject.download_file(remote_file, local_file)
    end
  end
end
