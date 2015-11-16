# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'chef/provisioner/version'

Gem::Specification.new do |spec|
  spec.name          = "chef-provisioner"
  spec.version       = Chef::Provisioner::VERSION
  spec.authors       = ["double-z"]
  spec.email         = ["zackzondlo@gmail.com"]

  spec.summary       = %q{"Gem For Orchestrating Provisioning"}
  spec.description   = %q{"See the README for more infoi"}
  spec.homepage      = "https://github.com/double-z/chef-provisioner"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  #if spec.respond_to?(:metadata)
    #spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  #else
    #raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  #end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "cheffish"
  spec.add_dependency "chef-provisioning"
  spec.add_dependency "chef-provisioning-vagrant"
  spec.add_dependency "chef-provisioning-ssh"

  spec.add_development_dependency "bundler", "~> 1.10.a"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end

#  spec.files         = `git ls-files -z`.split("\x0")
#  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
#  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
