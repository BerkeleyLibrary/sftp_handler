require 'berkeley_library/sftp_handler/downloader/base'
require 'spec_helper'
require 'tempfile'

describe BerkeleyLibrary::SftpHandler::Downloader::Base do
  describe '#download!' do
    it 'raises NotImplementedError' do
      expect{subject.download!}.to raise_error NotImplementedError
    end
  end

  describe '#assert_not_exists!' do
    it 'proceeds if file is absent' do
      expect { subject.assert_not_exists! '/path/to/non-existent-file' }.not_to raise_error
    end

    it 'raises if file exists' do
      Tempfile.open do |f|
        expect { subject.assert_not_exists! f.path }.to raise_error RuntimeError
      end
    end
  end

  describe '#connect' do
    before do
      ENV['LIT_BASE_HOST'] = 'foo.com'
      ENV['LIT_BASE_USERNAME'] = 'username'
      ENV['LIT_BASE_PASSWORD'] = 'password'
      ENV['LIT_BASE_KEYS'] = '/path/to/.ssh/id_rsa'
      ENV['LIT_BASE_KEY_DATA'] = "-----BEGIN RSA PRIVATE KEY-----\n...\n-----END RSA PRIVATE KEY-----\n"
    end

    it 'passes expected options and block' do
      block = ->(sftp) {}
      ssh_opts = {
        password: 'password',
        keys: [
          '/path/to/.ssh/id_rsa',
        ],
        key_data: [
          <<~KEY
          -----BEGIN RSA PRIVATE KEY-----
          ...
          -----END RSA PRIVATE KEY-----
          KEY
        ],
      }
      sftp_opts = {}

      expect(Net::SFTP)
        .to receive(:start)
        .with('foo.com', 'username', ssh_opts, sftp_opts) { |*args, **kwargs, &b|
          expect(b).to be(block)
        }

      subject.connect(&block)
    end
  end

  describe 'defaults' do
    context 'ENV is populated with defaults' do
      before(:all) do
        ENV['LIT_BASE_HOST'] = 'foo.com'
        ENV['LIT_BASE_USERNAME'] = 'the-username'
        ENV['LIT_BASE_PASSWORD'] = 'the-password'
        ENV['LIT_BASE_KEYS'] = 'private-key1,private-key2'
        ENV['LIT_BASE_KEY_DATA'] = 'key-data'
      end

      its(:host) { is_expected.to eq 'foo.com' }
      its(:username) { is_expected.to eq 'the-username' }
      its(:password) { is_expected.to eq 'the-password' }
      its(:keys) { is_expected.to eq ['private-key1', 'private-key2'] }
      its(:key_data) { is_expected.to eq ['key-data'] }
    end

    context 'ENV is empty' do
      before(:all) do
        ENV.delete('LIT_BASE_HOST')
        ENV.delete('LIT_BASE_USERNAME')
        ENV.delete('LIT_BASE_PASSWORD')
        ENV.delete('LIT_BASE_KEYS')
        ENV.delete('LIT_BASE_KEY_DATA')
      end

      its(:keys) { is_expected.to eq [] }
      its(:key_data) { is_expected.to eq [] }
    end
  end
end
