require 'spec_helper'

RSpec.shared_context('ssh', shared_context: :metadata) do
  attr_reader :ssh

  before do
    @ssh = instance_double(Net::SSH::Connection::Session)
    allow(Net::SSH).to receive(:start).with('testy', 'testy',{ password: 'testy', port: 22, append_all_supported_algorithms: true,sftp_options = { version: 3 }}).and_yield(ssh)
  end
end
