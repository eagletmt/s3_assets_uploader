require 'aws-sdk-s3'

module S3AssetsUploader
  class Config < Struct.new(:s3_client, :bucket, :assets_path, :assets_prefix, :additional_paths, :cache_control)
    class ValidationError < StandardError
    end

    DEFAULT_ASSETS_PATH = 'public/assets'.freeze
    DEFAULT_CACHE_CONTROL = 'max-age=2592000, public'

    def initialize
      self.assets_path = DEFAULT_ASSETS_PATH
      self.cache_control = DEFAULT_CACHE_CONTROL
      self.additional_paths = []
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
      additional_paths.each do |path|
        assert_under_public_path!(path)
      end
      self.s3_client ||= create_default_client
      true
    end

    private

    def create_default_client
      Aws::S3::Client.new
    end

    def assert_under_public_path!(path)
      if Pathname.new(path).relative_path_from(public_path).to_s.start_with?('../')
        raise ValidationError.new("#{path} must be under #{public_path}")
      end
      true
    end
  end
end
