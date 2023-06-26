# frozen_string_literal: true

require_relative "lib/anvil/version"

Gem::Specification.new do |spec|
  spec.name = "standard-procedure-anvil"
  spec.version = Anvil::VERSION
  spec.authors = ["Rahoul Baruah"]
  spec.email = ["rahoulb@standardprocedure.app"]

  spec.summary = "Tools for managing servers and apps built using dokku"
  spec.description = "Tools for managing servers and apps built using dokku"
  spec.homepage = "https://github.com/standard-procedure/anvil"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/standard-procedure/anvil"
  spec.metadata["changelog_uri"] = "https://github.com/standard-procedure/anvil"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "thor"
  spec.add_dependency "ed25519"
  spec.add_dependency "bcrypt_pbkdf"
  spec.add_dependency "net-ssh"
  spec.add_dependency "standard-procedure-async"
end
