# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'eater_atlas/version'

Gem::Specification.new do |spec|
  spec.name          = "eater_atlas"
  spec.version       = EaterAtlas::VERSION
  spec.authors       = ["Alexander Mancevice"]
  spec.email         = ["amancevice@cargometrics.com"]

  spec.summary       = "Lightweight model engine for food truck locations"
  #spec.description   = %q{TODO: Write a longer description or delete this line.}
  #spec.homepage      = "TODO: Put your gem's website or public repo URL here."

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.1"
  spec.add_development_dependency "rake",    "~> 13.0"

  spec.add_runtime_dependency "chronic",              "~> 0.10"
  spec.add_runtime_dependency "geocoder",             "~> 1.4"
  spec.add_runtime_dependency "oga",                  "~> 2.10"
  spec.add_runtime_dependency "sinatra",              "~> 2.0.1"
  spec.add_runtime_dependency "sinatra-contrib",      "~> 2.0"
  spec.add_runtime_dependency "sinatra-activerecord", "~> 2.0"
end
