require 's3_assets_uploader/uploader'
require 'mime/types'

RSpec.describe S3AssetsUploader::Uploader do
  let(:assets_path) { File.expand_path('../../fixtures/public/assets', __FILE__) }
  let(:assets_prefix) { nil }
  let(:cache_control) { 'public' }
  let(:additional_paths) { [] }
  let(:content_type) { nil }
  let(:bucket) { 'bucket-name' }
  let(:s3) { double('Aws::S3::Client') }
  let(:uploader) do
    described_class.new do |config|
      config.s3_client = s3
      config.bucket = bucket
      config.assets_path = assets_path
      config.assets_prefix = assets_prefix
      config.cache_control = cache_control
      config.additional_paths = additional_paths
      config.content_type = content_type
    end
  end

  describe '#upload' do
    it 'uploads files under assets_path' do
      expect(s3).to receive(:put_object).with(hash_including(bucket: bucket, key: 'assets/application-66ca0fe5fe1e99ca8e08bcddba209a3586654de41f80b810eec30a27790aef53.css'))
      expect(s3).to receive(:put_object).with(hash_including(bucket: bucket, key: 'assets/application-d3e5db26ec3f7b24a11084278a3e42cabf25ffa312bf25c6914d3874cc84396b.js'))
      uploader.upload
    end

    it 'uploads files using guessed content-type' do
      allow(MIME::Types).to receive(:type_for).with('application-66ca0fe5fe1e99ca8e08bcddba209a3586654de41f80b810eec30a27790aef53.css').and_return([double('mime', content_type: 'application/vnd.test')])
      allow(MIME::Types).to receive(:type_for).with('application-d3e5db26ec3f7b24a11084278a3e42cabf25ffa312bf25c6914d3874cc84396b.js').and_return([])
      expect(s3).to receive(:put_object).with(hash_including(bucket: bucket, key: 'assets/application-66ca0fe5fe1e99ca8e08bcddba209a3586654de41f80b810eec30a27790aef53.css', content_type: 'application/vnd.test'))
      expect(s3).to receive(:put_object).with(hash_including(bucket: bucket, key: 'assets/application-d3e5db26ec3f7b24a11084278a3e42cabf25ffa312bf25c6914d3874cc84396b.js', content_type: 'application/octet-stream'))

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

    context 'with cache_control' do
      let(:cache_control) { 'max-age=86400, public' }

      it 'uploads files with specified Cache-Control' do
        expect(s3).to receive(:put_object).with(hash_including(bucket: bucket, key: 'assets/application-66ca0fe5fe1e99ca8e08bcddba209a3586654de41f80b810eec30a27790aef53.css', cache_control: 'max-age=86400, public'))
        expect(s3).to receive(:put_object).with(hash_including(bucket: bucket, key: 'assets/application-d3e5db26ec3f7b24a11084278a3e42cabf25ffa312bf25c6914d3874cc84396b.js', cache_control: 'max-age=86400, public'))
        uploader.upload
      end
    end
  end

  describe 'guess_content_type' do
    let(:content_type) do
      proc do |path|
        next 'application/rss+xml' if path =~ /rss\.xml$/
        next 'application/atom+xml' if path =~ /atom\.xml$/
      end
    end

    it 'return custom content_type when matched' do
      expect(uploader.send(:guess_content_type, 'public/rss.xml')).to eq 'application/rss+xml'
    end
  end
end
