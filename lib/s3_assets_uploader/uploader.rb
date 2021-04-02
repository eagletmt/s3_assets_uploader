require 's3_assets_uploader/config'
require 'mime/types'

module S3AssetsUploader
  class Uploader
    def initialize(&block)
      @config = Config.new
      block.call(@config)
      @config.validate!
    end

    def upload
      upload_path(@config.assets_path)
      @config.additional_paths.each do |path|
        upload_path(Pathname.new(path))
      end
    end

    private

    def upload_path(path)
      if path.directory?
        path.each_child do |c|
          upload_path(c)
        end
      else
        path.open do |f|
          @config.s3_client.put_object(
            body: f,
            bucket: @config.bucket,
            key: compute_asset_key(path),
            content_type: guess_content_type(path),
            cache_control: @config.cache_control,
          )
        end
      end
    end

    def compute_asset_key(path)
      if @config.assets_prefix
        File.join(@config.assets_prefix, relative_path(path))
      else
        relative_path(path).to_s
      end
    end

    def guess_content_type(path)
      content_type = @config.guess_content_type(path)
      return content_type if content_type

      mime_type = MIME::Types.type_for(path.basename.to_s).first
      if mime_type
        mime_type.content_type
      else
        'application/octet-stream'
      end
    end

    def relative_path(path)
      path.relative_path_from(@config.public_path)
    end
  end
end
