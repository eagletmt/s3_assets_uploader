# S3AssetsUploader
[![Gem Version](https://badge.fury.io/rb/s3_assets_uploader.svg)](http://badge.fury.io/rb/s3_assets_uploader)
[![Build Status](https://travis-ci.org/eagletmt/s3_assets_uploader.svg?branch=master)](https://travis-ci.org/eagletmt/s3_assets_uploader)

Upload Rails assets to S3.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 's3_assets_uploader'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install s3_assets_uploader

## Usage

In Rakefile:

```ruby
require 's3_assets_uploader/rake_task'
namespace :assets do
  S3AssetsUploader::RakeTask.new(:upload) do |config|
    config.s3_client = Aws::S3::Client.new(region: 'ap-northeast-1')
    config.bucket = 'some-bucket'
  end
end
```

### Configurations
- `config.s3_client`
    - Aws::S3::Client instance to upload files
    - Default: `Aws::S3::Client.new`
- `config.bucket`
    - S3 bucket name
    - **Required**
- `config.assets_path`
    - Local path to assets directory
    - Default: `"public/assets"`
- `config.assets_prefix`
    - Remote assets path prefix
    - If set, public/assets/foo.png will be uploaded to `"#{assets_prefix}/assets/foo.png"`
    - Default: `nil`
- `config.additional_paths`
    - Additional directories to upload
    - Default: `[]`
- `config.cache_control`
    - cache_control option for S3
    - Default: `"max-age=2592000, public"`

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/eagletmt/s3_assets_uploader/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
