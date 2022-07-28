# frozen_string_literal: true

require_relative "lib/rails/openapi/version"

Gem::Specification.new do |spec|
  spec.name = "rails-openapi"
  spec.version = Rails::Openapi::VERSION
  spec.authors = ["Kenaniah Cerny"]
  spec.email = ["kenaniah@gmail.com"]

  spec.summary = "Creates rails engines from OpenAPI specification files"
  spec.homepage = "https://github.com/kenaniah/rails-openapi"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/kenaniah/rails-openapi/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").select { |f| f.match(/lib\/|sig\//) }
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "rails", "~> 6"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rails", "~> 6"
  spec.add_development_dependency "rake"
end
