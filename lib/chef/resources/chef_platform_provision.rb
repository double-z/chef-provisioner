require 'cheffish'
require 'chef/provisioning'
require 'chef/resource/machine'

class Chef
  class Resource
    class ChefPlatformProvisionServices < Chef::Resource::Machine

      def initialize(*args)
        # We are using the name as the policy group 
        # but need the name to be the node_name of
        # the provisioner node so we swap them out 
        args.each do |k|
          policy_group(k) if k.kind_of?(String)
        end
        args.collect! { |element|
          (element.kind_of?(String)) ? Chef::Config[:node_name] : element
        }
        super
      end

      def policy_group(arg_val = nil)
        @policy_group ||= arg_val
      end

      resource_name :chef_platform_provision_services

      self.resource_name = 'chef_platform_provision_services'

      actions :_test_ready, :reconfigure, :generate_config, :notify_reconfigure, :destroy_all
      default_action :nothing

      attribute :package_installer, :kind_of => String, :default => "deb"
      attribute :chef_server_package_source
      attribute :init_time, :kind_of => String, :default => Time.now.strftime("%Y%m%d%H%M%S")
      attribute :policy_group, :kind_of => String

      attribute :driver_name, :kind_of => String

      attribute :chef_server_topology, :kind_of => String
      attribute :chef_server_version
      attribute :chef_server_api_fqdn
      attribute :chef_server_configuration, :kind_of => Hash

      attribute :analytics_version
      attribute :analytics_api_fqdn, :kind_of => String
      attribute :analytics_configuration, :kind_of => Hash

      attribute :delivery_version
      attribute :delivery_api_fqdn
      attribute :delivery_configuration, :kind_of => Hash

      attribute :supermarket_version
      attribute :supermarket_api_fqdn
      attribute :supermarket_configuration, :kind_of => Hash

      attribute :nodes, :kind_of => Array

    end
  end
end
