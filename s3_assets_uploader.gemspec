# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 's3_assets_uploader/version'

Gem::Specification.new do |spec|
  spec.name          = "s3_assets_uploader"
  spec.version       = S3AssetsUploader::VERSION
  spec.authors       = ["Kohei Suzuki"]
  spec.email         = ["eagletmt@gmail.com"]

  spec.summary       = %q{Upload Rails assets to S3.}
  spec.description   = %q{Upload Rails assets to S3.}
  spec.homepage      = "https://github.com/eagletmt/s3_assets_uploader"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "aws-sdk", ">= 2.0"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", ">= 3.0"
end
