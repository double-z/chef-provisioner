require 'cheffish'
require 'chef/provisioning'
require 'chef/provider/lwrp_base'
require 'chef/provider/chef_node'
# require 'chef/provisioner'
# require "yaml"
# require 'ap'
# require 'pp'
class Chef
  class Provider
    class ChefPlatformProvisionServices < Chef::Provider::LWRPBase

      include Chef::Provisioner::Platform
      include Chef::Provisioner::Platform::Coordinator
      include Chef::Provisioner::Platform::DataHandler
      include Chef::Provisioner::Helpers
      include Chef::Provisioner::Paths
      include Chef::Provisioner::MachineOptions

      def action_handler
        @action_handler ||= Chef::Provisioning::ChefProviderActionHandler.new(self)
      end

      ############################################
      #
      # Public Actions. Accessible from recipe.
      #
      #    - reconfigure
      #    - destroy_all
      #
      ############################################

      action :notify_reconfigure do
        reconfigure_updated = action_reconfigure_all
        @new_resource.updated_by_last_action(reconfigure_updated)
      end

      action :reconfigure do
        # reconfigure_updated = should_run? ? action_reconfigure_all : false
        if !all_nodes_ready?
          reconfigure_updated = action_ready_nodes
          # elsif (all_nodes_ready? &&
          #        !(new_platform_spec.all_nodes.count == current_platform_spec.all_nodes.count))
          #   raise "You need to use the :scale_frontends or :scale_builders to modify node count on an existing cluster"
        elsif all_nodes_ready? # & platform_configuration_updated?
          reconfigure_updated = action_reconfigure_all
        else
          log "#{policy_group.upcase} Platform Configuration and Nodes Up to Date"
        end
        @new_resource.updated_by_last_action(reconfigure_updated)
      end

      action :destroy_all do
        action_allocate
        destroy_machines.run_action(:destroy)
        current_platform_spec.delete(action_handler) if destroy_machines.updated_by_last_action?
        @new_resource.updated_by_last_action(destroy_machines.updated_by_last_action?)
      end

      ############################################
      #
      # Private Actions. Access is restricted
      #
      #    - allocate
      #    - ready
      #    - reconfigure_bootstrap
      #    - reconfigure_all
      #
      ############################################

      # PRIVATE ACTION: allocate
      action :allocate do
        [platform_policy_group_cache_path,
         local_chef_server_cache_path,
         local_chef_server_supermarket_path,
         local_analytics_cache_path,
         local_delivery_cache_path
        ].each do |path|
          action = (new_resource.action == :destroy_all) ? :delete : :create
          create_or_delete_directory(action, path)
        end
      end

      # PRIVATE ACTION: ready
      action :ready_nodes do
        ready_updated_by_action = false
        # As of Now, what you start with is what you get
        # - I.E nodes may not be modified as far as:
        # -- Name. At All. ex. node name, hostname, domain et al
        # -- IP's
        # TODO:
        # Once All Nodes are set they will be modifiable in two ways:
        # * action :scale_frontends
        # * action :scale_builders
        #
        # With that being the case - immutable nodes:
        # We take no action if the node array exists already, and we tell people as much
        # via updated_by_last_action
        # if !all_nodes_ready? && (new_resource.action == :scale_frontends ||
        #                          new_resource.action == :scale_builders)
        # else
        if !all_nodes_ready?
          action_allocate
          initial_converge_blank_machines.run_action(:converge)
          node_array = get_initial_converge_machine_data(initial_converge_blank_machines.machines)
          new_platform_spec.nodes = node_array
          pre_save_ready_machine_attrs_to_nodes(node_array)
          new_platform_spec.save_to_chef_platform_ready_nodes_data_bag(action_handler)
          ready_machines.run_action(:converge)
          ready_updated_by_action = ready_machines.updated_by_last_action?
          ruby_block 'notify_reconfigure_ready' do
            block do
              new_platform_spec.status = "ready_notify_reconfigure"
              new_platform_spec.save(action_handler)
            end
            action :nothing unless ready_updated_by_action
            notifies :notify_reconfigure, "chef_platform_provision_services[#{policy_group}]", :immediately
          end
        end
        new_resource.updated_by_last_action(ready_updated_by_action)
      end

      # PRIVATE ACTION: reconfigure_bootstrap
      action :reconfigure_bootstrap do
        # ready_updated = false
        bootstrap_node_updated = false
        #   ready_updated = action_ready_nodes
        #   @reconfigure_action = ready_updated ? :converge_only : :converge
        @reconfigure_action = :converge
        server = new_platform_spec.chef_server_nodes[0]
        bootstrap_machine()
        bootstrap_machine.run_action(@reconfigure_action)
        bootstrap_node_updated = bootstrap_machine.updated_by_last_action?
        if (bootstrap_node_updated && !chef_server_standalone_only?)
          # FileMover::Download.all_files_from_bootstrap
          # files_updated = download_all_files_from_bootstrap
          download_files_from_bootstrap
          upload_bootsrap_files_to_non_bootstrap_nodes # if files_updated
        end
        new_platform_spec.status = "bootstrap_reconfigured"
        new_platform_spec.save(action_handler)
        # end
        @new_resource.updated_by_last_action(bootstrap_node_updated)
      end

      def reconfigure_non_bootstrap_non_builders(reconfigure_spec)
      end

      # PRIVATE ACTION: reconfigure_all
      action :reconfigure_all do
        bootstrap_updated = action_reconfigure_bootstrap
        if bootstrap_updated && !chef_server_standalone_only?
          reconfigure_action = @reconfigure_action || :converge
          non_bootstrap_non_builder_machines.run_action(reconfigure_action)
          new_platform_spec.status = "cluster_bootstraped_reconfigured"
          new_platform_spec.save(action_handler)
        end
        @new_resource.updated_by_last_action(bootstrap_updated)
      end

      ############################################
      #
      # Begin Non Action Methods
      #
      ############################################

      attr_reader :policy_group, :new_platform_spec, :current_platform_spec, :rollback_platform_spec

      def load_current_resource
        @policy_group = new_resource.policy_group
        @current_platform_spec = Chef::Provisioner::ChefPlatformSpec.current_spec(policy_group)
        puts "Class"
        puts current_platform_spec.nodes.class
        puts "empty"
        puts current_platform_spec.nodes.empty?.to_s unless current_platform_spec.nodes.nil?
        puts "cps nodes"
        puts         current_platform_spec.nodes
        puts "new_platform_data"
        puts new_platform_data

        @new_platform_spec = Chef::Provisioner::ChefPlatformSpec.new_spec(policy_group,
                                                                          new_platform_data)
        new_platform_spec.nodes = all_ready_nodes if all_nodes_ready?
      end
    end

  end
end
