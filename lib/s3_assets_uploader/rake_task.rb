require 'rake/tasklib'
require 's3_assets_uploader/uploader'

module S3AssetsUploader
  class RakeTask < Rake::TaskLib
    include Rake::DSL

    def initialize(name, &block)
      desc 'Upload assets to S3'
      task name do
        Uploader.new(&block).upload
      end
    end
  end
end
