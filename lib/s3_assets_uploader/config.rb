require 'aws-sdk'

module S3AssetsUploader
  class Config < Struct.new(:s3_client, :bucket, :assets_path, :assets_prefix)
    class ValidationError < StandardError
    end

    DEFAULT_ASSETS_PATH = 'public/assets'.freeze

    def initialize
      self.assets_path = DEFAULT_ASSETS_PATH
    end

    def assets_path
      Pathname.new(self[:assets_path])
    end

    def public_path
      assets_path.parent
    end

    def validate!
      if bucket.nil?
        raise ValidationError.new('config.bucket must be set')
      end
      self.s3_client ||= create_default_client
      true
    end

    private

    def create_default_client
      Aws::S3::Client.new
    end
  end
end
