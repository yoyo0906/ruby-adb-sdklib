# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'adb_sdklib/version'

Gem::Specification.new do |spec|
  spec.name          = "adb-sdklib"
  spec.version       = AdbSdkLib::VERSION
  spec.authors       = ["yoyo0906"]
  spec.email         = ["yoyo0906@gmail.com"]
  spec.summary       = "Android Debug Bridge (ADB) wrapper" +
                       " using Android SDK Tools Library with Rjb."
  spec.description   = "Ruby library for basic access to Android devices through" +
                       " ADB using ddmlib.jar which is included Android SDK Tools" +
                       " via Rjb (Ruby Java Bridge)."
  spec.homepage      = "http://github.com/yoyo0906/ruby-adb-sdklib"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'rjb'

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
