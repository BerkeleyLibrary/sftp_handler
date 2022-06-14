require 'berkeley_library/sftp_handler/downloader/gobi'
require 'net/sftp'
require 'spec_helper'

describe BerkeleyLibrary::SftpHandler::Downloader::Gobi do
  let(:now) { Time.new(2022, 5, 20, 0, 0, 0) }

  its(:default_host) { is_expected.to eq 'ftp.ybp.com' }
  its(:default_username) { is_expected.to eq 'berkeley' }
  its(:ssh_options) { is_expected.to include(append_all_supported_algorithms: true) }

  its(:default_filename) do
    Timecop.freeze(now) do
      is_expected.to eq 'ebook0520.ord'
    end
  end

  describe '#download!' do
    let(:ten_days_ago) { Time.new(2022, 5, 10, 0, 0, 0).to_i }
    let(:remote_path) { Pathname.new('/gobiord/ebook0520.ord') }
    let(:sftp_session) { instance_double(Net::SFTP::Session) }

    before do
      Timecop.freeze(now)
      expect(Net::SFTP)
        .to receive(:start)
        .and_yield(sftp_session)
    end

    after do
      Timecop.unfreeze
    end

    it 'downloads a recent file' do
      expect(sftp_session)
        .to receive(:stat!)
        .with(remote_path)
        .and_return(Net::SFTP::Protocol::V01::Attributes.new(mtime: ten_days_ago))
      expect(sftp_session)
        .to receive(:download!)
        .with('/gobiord/ebook0520.ord', '/opt/app/data/ebook0520.ord')

      subject.download!
    end

    it 'skips an older file' do
      expect(sftp_session)
        .to receive(:stat!)
        .with(remote_path)
        .and_return(Net::SFTP::Protocol::V01::Attributes.new(mtime: ten_days_ago))
      expect(sftp_session).not_to receive(:download!)

      subject.download!(modified_after: '9 days ago')
    end
  end
end
