# frozen_string_literal: true

require_relative "lib/processable_queue/version"

Gem::Specification.new do |spec|
  spec.name = "processable_queue"
  spec.version = ProcessableQueue::VERSION
  spec.authors = ["isidzukuri"]
  spec.email = ["axesigon@gmail.com"]

  spec.summary = "Processes batch of items in parallel threads"
  spec.description = "Processes batch of items in parallel threads"
  spec.homepage = "https://github.com/isidzukuri/processable_queue"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "https://github.com/isidzukuri/processable_queue"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/isidzukuri/processable_queue"
  spec.metadata["changelog_uri"] = "https://github.com/isidzukuri/processable_queue"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "colorize", "~> 1.1"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
