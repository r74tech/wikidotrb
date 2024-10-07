# frozen_string_literal: true

require_relative "lib/wikidotrb/version"

Gem::Specification.new do |spec|
  spec.name = "wikidotrb"
  spec.version = "3.0.7.pre.6"
  spec.authors = ["r74tech"]
  spec.email = ["r74tech@gmail.com"]

  spec.summary = "A utility library for interacting with Wikidot, inspired by wikidot.py."
  spec.description = "Wikidotrb is a Ruby library inspired by wikidot.py, providing utility functions to interact with the Wikidot platform, making it easier to automate and manage content."
  spec.homepage = "https://github.com/r74tech/wikidotrb"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/r74tech/wikidotrb"
  spec.metadata["changelog_uri"] = "https://github.com/r74tech/wikidotrb/blob/main/wikidotrb/CHANGELOG.md"

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Specify dependencies
  spec.add_dependency "concurrent-ruby", "~> 1.1"
  spec.add_dependency "httpx", "~> 1.3"
  spec.add_dependency "json", "~> 2.0"
  spec.add_dependency "logger", "~> 1.4"
  spec.add_dependency "nokogiri", "~> 1.12"

  # Development dependencies
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.10"
  spec.add_development_dependency "rubocop", "~> 1.21"
  spec.metadata["rubygems_mfa_required"] = "true"
end
