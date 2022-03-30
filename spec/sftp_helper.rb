require 'spec_helper'

RSpec.shared_context('sftp', shared_context: :metadata) do
  attr_reader :sftp

  before do
    @sftp = instance_double(Net::SFTP::Session)
    pass = { password: 'password', port: 22, append_all_supported_algorithms: true }

    # rubocop:disable Lint/UselessAssignment
    allow(Net::SFTP).to receive(:start).with('host', 'user', pass, sftp_options = { version: 3 }).and_return(@sftp)
    # rubocop:enable Lint/UselessAssignment

  end
end
