require 'berkeley_library/sftp_handler/downloader/lbnl'
require 'net/sftp'
require 'spec_helper'
require 'tempfile'

describe BerkeleyLibrary::SftpHandler::Downloader::Lbnl do
  its(:default_host) { is_expected.to eq 'ncc-1701.lbl.gov' }
  its(:default_username) { is_expected.to eq 'ucblib' }

  describe '#download!' do
    let(:now) { Time.new(2022, 5, 25, 0, 0, 0) }
    let(:last_weeks_filename) { 'lbnl_people_20220516.zip' }
    let(:this_weeks_filename) { 'lbnl_people_20220523.zip' }
    let(:todays_remote_path) { Pathname.new(this_weeks_filename) }
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

    it "downloads this week's file" do
      expect(sftp_session)
        .to receive(:download!)
        .with(todays_remote_path.to_s, Pathname.new("/opt/app/data/#{this_weeks_filename}").to_s)

      subject.download!
    end

    it "downloads to an alternate local_dir" do
      local_dir = '/netapp/alma/lbnl_patrons'

      expect(sftp_session)
        .to receive(:download!)
        .with(todays_remote_path.to_s, Pathname.new("#{local_dir}/#{this_weeks_filename}").to_s)

      subject.download!(local_dir: local_dir)
    end

    it "downloads a specific file" do
      filename = 'lbnl_people_20220516.zip'
      remote_path = Pathname.new(filename)
      local_path = Pathname.new("/opt/app/data/#{filename}")

      expect(sftp_session)
        .to receive(:download!)
        .with(remote_path.to_s, local_path.to_s)

      subject.download!(filename: filename)
    end
  end

  describe '#assert_file_not_processed!' do
    it 'proceeds if processed file is absent' do
      expect { subject.assert_file_not_processed!('/path/to/non-existent-file') }.not_to raise_error
    end

    it 'raises if processed file exists' do
      f = Tempfile.new(['temp_file38348', '.old'])
      expect { subject.assert_file_not_processed! f.path.gsub('.old', '') }.to raise_error RuntimeError
    end
  end

  describe '#default_filename' do
    context 'on Sunday May 29, 2022' do
      its(:default_filename) do
        Timecop.freeze(Time.new(2022, 5, 29, 23, 59, 59)) do
          is_expected.to eq 'lbnl_people_20220523.zip'
        end
      end
    end

    context 'on Monday May 30, 2022' do
      its(:default_filename) do
        Timecop.freeze(Time.new(2022, 5, 30, 23, 59, 59)) do
          is_expected.to eq 'lbnl_people_20220530.zip'
        end
      end
    end

    context 'on Tuesday May 31, 2022' do
      its(:default_filename) do
        Timecop.freeze(Time.new(2022, 5, 31, 0, 0, 0)) do
          is_expected.to eq 'lbnl_people_20220530.zip'
        end
      end
    end

    context 'on Wednesday May 25, 2022' do
      its(:default_filename) do
        Timecop.freeze(Time.new(2022, 5, 25, 23, 59, 59)) do
          is_expected.to eq 'lbnl_people_20220523.zip'
        end
      end
    end
  end
end
