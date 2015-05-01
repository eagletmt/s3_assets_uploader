require 's3_assets_uploader/config'

RSpec.describe S3AssetsUploader::Config do
  let(:config) { described_class.new }

  before do
    # Avoid slow test
    allow(config).to receive(:create_default_client)
  end

  describe '#validate!' do
    it 'requires bucket' do
      expect { config.validate! }.to raise_error(S3AssetsUploader::Config::ValidationError, /bucket/)
    end

    context 'with bucket' do
      before do
        config.bucket = 'some-bucket'
      end

      it 'passes' do
        expect { config.validate! }.to_not raise_error
      end

      context 'with invalid additional_paths' do
        before do
          config.assets_path = File.expand_path('../../fixtures/public/assets', __FILE__)
          config.additional_paths << __FILE__
        end

        it 'rejects additional_paths which is not under public_path' do
          expect { config.validate! }.to raise_error(S3AssetsUploader::Config::ValidationError, /must be under/)
        end
      end
    end
  end
end
