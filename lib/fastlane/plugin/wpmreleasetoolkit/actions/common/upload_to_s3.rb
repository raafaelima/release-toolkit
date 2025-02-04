require 'fastlane/action'
require 'digest/sha1'

module Fastlane
  module Actions
    module SharedValues
      S3_UPLOADED_FILE_PATH = :S3_UPLOADED_FILE_PATH
    end

    class UploadToS3Action < Action
      def self.run(params)
        file_path = params[:file]
        file_name = File.basename(file_path)

        bucket = params[:bucket]
        key = params[:key] || file_name

        if params[:auto_prefix] == true
          file_name_hash = Digest::SHA1.hexdigest(file_name)
          key = [file_name_hash, key].join('/')
        end

        if file_is_already_uploaded?(bucket, key)
          message = "File already exists in S3 bucket #{bucket} at #{key}"
          if params[:skip_if_exists]
            UI.important("#{message}. Skipping upload.")
            return key
          else
            UI.user_error!(message)
          end
        end

        UI.message("Uploading #{file_path} to: #{key}")

        File.open(file_path, 'rb') do |file|
          Aws::S3::Client.new().put_object(
            body: file,
            bucket: bucket,
            key: key
          )
        rescue Aws::S3::Errors::ServiceError => e
          UI.crash!("Unable to upload file to S3: #{e.message}")
        end

        UI.success('Upload Complete')

        Actions.lane_context[SharedValues::S3_UPLOADED_FILE_PATH] = key

        return key
      end

      def self.file_is_already_uploaded?(bucket, key)
        response = Aws::S3::Client.new().head_object(
          bucket: bucket,
          key: key
        )
        return response[:content_length].positive?
      rescue Aws::S3::Errors::NotFound
        return false
      end

      def self.description
        'Uploads a given file to S3'
      end

      def self.authors
        ['Automattic']
      end

      def self.return_value
        'Returns the object\'s derived S3 key'
      end

      def self.details
        'Uploads a file to S3, and makes a pre-signed URL available in the lane context'
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :bucket,
            description: 'The bucket that will store the file',
            optional: false,
            type: String,
            verify_block: proc { |bucket| UI.user_error!('You must provide a valid bucket name') if bucket.empty? }
          ),
          FastlaneCore::ConfigItem.new(
            key: :key,
            description: 'The path to the file within the bucket. If `nil`, will default to the `file\'s basename',
            optional: true,
            type: String,
            verify_block: proc { |key|
              next if key.is_a?(String) && !key.empty?

              UI.user_error!('The provided key must not be empty. Use nil instead if you want to default to the file basename')
            }
          ),
          FastlaneCore::ConfigItem.new(
            key: :file,
            description: 'The path to the local file on disk',
            optional: false,
            type: String,
            verify_block: proc { |f| UI.user_error!("Path `#{f}` does not exist.") unless File.file?(f) }
          ),
          FastlaneCore::ConfigItem.new(
            key: :auto_prefix,
            description: 'Generate a derived prefix based on the filename that makes it harder to guess the URL of the uploaded object',
            optional: true,
            default_value: true,
            type: Boolean
          ),
          FastlaneCore::ConfigItem.new(
            key: :skip_if_exists,
            description: 'If the file already exists in the S3 bucket, skip the upload (and report it in the logs), instead of failing with `user_error!`',
            optional: true,
            default_value: false,
            type: Boolean
          ),
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
