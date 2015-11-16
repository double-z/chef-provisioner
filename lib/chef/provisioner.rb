# $:.unshift(File.expand_path(File.dirname(__FILE__))) unless
#     $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
    
require "cheffish"
require "chef/provisioning"
require "chef/provisioner/version"
require "chef/provisioner/helpers"
require "chef/provisioner/chef_platform_spec"
require "chef/provisioner/platform"
require "chef/provisioner/machine_options"
require "chef/provisioner/paths"
require "chef/provisioner/dsl"
require "chef/providers/chef_platform_provision"
require "chef/resources/chef_platform_provision"
# require_relative "./provisioner/version.rb"
# require_relative "./provisioner/helpers.rb"
# require_relative "./provisioner/platform.rb"
# require_relative "./provisioner/machine_options.rb"
# require_relative "./provisioner/paths.rb"
# require_relative "./provisioner/dsl.rb"
# require_relative "./providers/chef_platform_provision.rb"
# require_relative "./resources/chef_platform_provision.rb"

class Chef
  module Provisioner

  end
end
