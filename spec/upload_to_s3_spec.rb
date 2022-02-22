require 'tempfile'
require_relative './spec_helper'

describe Fastlane::Actions::UploadToS3Action do
  let(:client) { instance_double(Aws::S3::Client) }
  let(:test_bucket) { 'a8c-wpmrt-unit-tests-bucket' }

  before do
    allow(Aws::S3::Client).to receive(:new).and_return(client)
  end

  # Stub head_object to return a specific content_length
  def stub_s3_head_request(key, content_length)
    allow(client).to receive(:head_object)
      .with(bucket: test_bucket, key: key)
      .and_return(Aws::S3::Types::HeadObjectOutput.new(content_length: content_length))
  end

  describe 'uploading a file' do
    it 'generates a prefix for the key by default' do
      in_tmp_dir do |tmp_dir|
        file_path = File.join(tmp_dir, 'input_file_1')
        File.write(file_path, '')
        expected_key = '939c39398db2405e791e205778ff70f85dff620e/a8c-key1'

        stub_s3_head_request(expected_key, 0) # File does not exist in S3
        expect(client).to receive(:put_object).with(body: file_instance_of(file_path), bucket: test_bucket, key: expected_key)

        return_value = run_described_fastlane_action(
          bucket: test_bucket,
          key: 'a8c-key1',
          file: file_path
        )

        expect(return_value).to eq(expected_key)
        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::S3_UPLOADED_FILE_PATH]).to eq(expected_key)
      end
    end

    it 'generates a prefix for the key when using auto_prefix:true' do
      in_tmp_dir do |tmp_dir|
        file_path = File.join(tmp_dir, 'input_file_2')
        File.write(file_path, '')
        expected_key = '8bde1a7a04300df27b52f4383dc997e5fbbff180/a8c-key2'

        stub_s3_head_request(expected_key, 0) # File does not exist in S3
        expect(client).to receive(:put_object).with(body: file_instance_of(file_path), bucket: test_bucket, key: expected_key)

        return_value = run_described_fastlane_action(
          bucket: test_bucket,
          key: 'a8c-key2',
          file: file_path,
          auto_prefix: true
        )

        expect(return_value).to eq(expected_key)
        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::S3_UPLOADED_FILE_PATH]).to eq(expected_key)
      end
    end

    it 'uses the provided key verbatim when using auto_prefix:false' do
      in_tmp_dir do |tmp_dir|
        file_path = File.join(tmp_dir, 'input_file_1')
        File.write(file_path, '')
        expected_key = 'a8c-key1'

        stub_s3_head_request(expected_key, 0) # File does not exist in S3
        expect(client).to receive(:put_object).with(body: file_instance_of(file_path), bucket: test_bucket, key: expected_key)

        return_value = run_described_fastlane_action(
          bucket: test_bucket,
          key: 'a8c-key1',
          file: file_path,
          auto_prefix: false
        )

        expect(return_value).to eq(expected_key)
        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::S3_UPLOADED_FILE_PATH]).to eq(expected_key)
      end
    end

    it 'correctly appends the key if it contains subdirectories' do
      in_tmp_dir do |tmp_dir|
        file_path = File.join(tmp_dir, 'input_file_1')
        File.write(file_path, '')
        expected_key = '939c39398db2405e791e205778ff70f85dff620e/subdir/a8c-key1'

        stub_s3_head_request(expected_key, 0) # File does not exist in S3
        expect(client).to receive(:put_object).with(body: file_instance_of(file_path), bucket: test_bucket, key: expected_key)

        return_value = run_described_fastlane_action(
          bucket: test_bucket,
          key: 'subdir/a8c-key1',
          file: file_path
        )

        expect(return_value).to eq(expected_key)
        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::S3_UPLOADED_FILE_PATH]).to eq(expected_key)
      end
    end

    it 'uses the filename as the key if one is not provided' do
      expected_key = 'c125bd799c6aad31092b02e440a8fae25b45a2ad/test_file_1'

      with_tmp_file_path_for_file_named('test_file_1') do |file_path|
        stub_s3_head_request(expected_key, 0) # File does not exist in S3
        expect(client).to receive(:put_object).with(body: file_instance_of(file_path), bucket: test_bucket, key: expected_key)

        return_value = run_described_fastlane_action(
          bucket: test_bucket,
          file: file_path
        )

        expect(return_value).to eq(expected_key)
        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::S3_UPLOADED_FILE_PATH]).to eq(expected_key)
      end
    end

    it 'fails if bucket is empty or nil' do
      expect do
        with_tmp_file_path do |file_path|
          run_described_fastlane_action(
            bucket: '',
            key: 'key',
            file: file_path
          )
        end
      end.to raise_error(FastlaneCore::Interface::FastlaneError, 'You must provide a valid bucket name')
    end

    it 'fails if an empty key is provided' do
      expect do
        with_tmp_file_path do |file_path|
          run_described_fastlane_action(
            bucket: test_bucket,
            key: '',
            file: file_path
          )
        end
      end.to raise_error(FastlaneCore::Interface::FastlaneError, 'You must provide a valid key')
    end

    it 'fails if local file does not exist' do
      expect do
        run_described_fastlane_action(
          bucket: test_bucket,
          key: 'key',
          file: 'this-file-does-not-exist.txt'
        )
      end.to raise_error(FastlaneCore::Interface::FastlaneError, 'Unable to read file at this-file-does-not-exist.txt')
    end

    it 'fails if the file already exists on S3' do
      expected_key = 'a62f2225bf70bfaccbc7f1ef2a397836717377de/key'
      stub_s3_head_request(expected_key, 1) # File already exists on S3

      with_tmp_file_path_for_file_named('key') do |file_path|
        expect do
          run_described_fastlane_action(
            bucket: test_bucket,
            key: 'key',
            file: file_path
          )
        end.to raise_error(FastlaneCore::Interface::FastlaneError, "File already exists at #{expected_key}")
      end
    end
  end
end
