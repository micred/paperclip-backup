# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "paperclip/backup/version"

Gem::Specification.new do |spec|
  spec.name          = "paperclip-backup"
  spec.version       = Paperclip::Backup::VERSION
  spec.authors       = ["Michele Redolfi"]
  spec.email         = ["michele@moku.io"]
  spec.summary       = %q{Easy backup of Paperclip attachments in the cloud with Amazon Glacier.}
  spec.description   = %q{paperclip-backup do incremental backups of the attachments in Amazon Glacier (long-term/infrequently accessed storage). It is meant to be a low cost disaster recovery solution of your Paperclip attachments.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activemodel", ">= 4.1.0"
  spec.add_dependency "paperclip", ">= 4.2.0"
  spec.add_dependency "rubyzip", ">= 1.1.7"
  spec.add_dependency "fog", ">= 1.38.0"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
