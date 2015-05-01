require 's3_assets_uploader/uploader'

RSpec.describe S3AssetsUploader::Uploader do
  let(:assets_path) { File.expand_path('../../fixtures/public/assets', __FILE__) }
  let(:assets_prefix) { nil }
  let(:additional_paths) { [] }
  let(:bucket) { 'bucket-name' }
  let(:s3) { double('Aws::S3::Client') }
  let(:uploader) do
    described_class.new do |config|
      config.s3_client = s3
      config.bucket = bucket
      config.assets_path = assets_path
      config.assets_prefix = assets_prefix
      config.additional_paths = additional_paths
    end
  end

  describe '#upload' do
    it 'uploads files under assets_path' do
      expect(s3).to receive(:put_object).with(hash_including(bucket: bucket, key: 'assets/application-66ca0fe5fe1e99ca8e08bcddba209a3586654de41f80b810eec30a27790aef53.css'))
      expect(s3).to receive(:put_object).with(hash_including(bucket: bucket, key: 'assets/application-d3e5db26ec3f7b24a11084278a3e42cabf25ffa312bf25c6914d3874cc84396b.js'))
      uploader.upload
    end

    context 'with assets_prefix' do
      let(:assets_prefix) { 'some-prefix' }

      it 'uploads files prefixed with assets_prefix' do
        expect(s3).to receive(:put_object).with(hash_including(bucket: bucket, key: 'some-prefix/assets/application-66ca0fe5fe1e99ca8e08bcddba209a3586654de41f80b810eec30a27790aef53.css'))
        expect(s3).to receive(:put_object).with(hash_including(bucket: bucket, key: 'some-prefix/assets/application-d3e5db26ec3f7b24a11084278a3e42cabf25ffa312bf25c6914d3874cc84396b.js'))
        uploader.upload
      end
    end

    context 'with additional_paths' do
      let(:additional_paths) { [File.expand_path('../../fixtures/public/fonts', __FILE__)] }

      it 'also uploads additional_paths' do
        expect(s3).to receive(:put_object).with(hash_including(bucket: bucket, key: 'assets/application-66ca0fe5fe1e99ca8e08bcddba209a3586654de41f80b810eec30a27790aef53.css'))
        expect(s3).to receive(:put_object).with(hash_including(bucket: bucket, key: 'assets/application-d3e5db26ec3f7b24a11084278a3e42cabf25ffa312bf25c6914d3874cc84396b.js'))
        expect(s3).to receive(:put_object).with(hash_including(bucket: bucket, key: 'fonts/fontawesome-webfont.ttf'))
        uploader.upload
      end
    end
  end
end
