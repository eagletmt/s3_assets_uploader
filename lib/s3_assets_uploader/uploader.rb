require 's3_assets_uploader/config'

module S3AssetsUploader
  class Uploader
    def initialize(&block)
      @config = Config.new
      block.call(@config)
      @config.validate!
    end

    def upload
      upload_path(@config.assets_path)
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

    def relative_path(path)
      path.relative_path_from(@config.public_path)
    end
  end
end
