# frozen_string_literal: true

require_relative "lib/bitmovin/version"

Gem::Specification.new do |spec|
  spec.name = "dcmp_bitmovin"
  spec.version = Bitmovin::VERSION
  spec.authors = ["Rob Flynn", "David Prater"]
  spec.email = ["rflynn@dcmp.org", "dprater@dcmp.org"]

  spec.summary = "DCMP's Bitmovin integration"
  spec.description = "Write a longer description or delete this line."
  spec.homepage = "https://github.com/dcmp/dcmp_bitmovin"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/dcmp/dcmp_bitmovin"


  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "faraday", ">= 2.12.0"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake", "~> 10.4"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
