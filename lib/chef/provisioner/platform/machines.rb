require 'chef/util/file_edit'
require 'chef/sugar/core_extensions'
require 'chef/sugar/ip'


class Chef
  module Provisioner
    module Platform
      module Machines

        ##
        # Machine Resources

        def destroy_machines
          @destroy_machines ||= begin
            mbd = machine_batch 'machine_batch_destroy_all' do
              action :nothing
              new_platform_spec.all_nodes.each do |server|
                machine server['node_name'] do
                  driver new_platform_spec.driver_name
                  machine_options machine_opts_for(server)
                end
              end
            end
            mbd
          end
        end

        def initial_converge_blank_machines
          @initial_converge_blank_machines ||= begin
            rmb = machine_batch 'machine_batch_initial_converge_blank_machines' do
              new_platform_spec.all_nodes.each do |server|
                machine server['node_name'] do
                  driver new_platform_spec.driver_name
                  machine_options machine_opts_for(server)
                  complete true
                  not_if do
                    server['ipaddress']
                  end
                end
              end
              action :nothing
            end
            rmb
          end
        end

        def get_initial_converge_machine_data(servers)
          node_array = []
          servers.each do |ready_machine|
            node_driver = Chef::Provider::ChefNode.new(ready_machine, run_context)
            node_driver.load_current_resource
            json = Chef::Provisioner::Helpers.deep_hashify(node_driver.new_json)
            new_platform_spec.all_nodes.each do |_server|
              server = Chef::Provisioner::Helpers.deep_hashify(_server)
              if (ready_machine.name.to_s == server['node_name'])
                node_interfaces = json["automatic"]["network"]["interfaces"]
                node_interfaces["#{server['interface']}"]["addresses"].each do |k,v|
                  server['ipaddress'] = k.to_s if (v["family"] == "inet")
                  node_array << server if (server['ipaddress'] && (v["family"] == "inet"))
                end
              end
            end
          end
          node_array
        end

        def pre_save_ready_machine_attrs_to_nodes(node_array, chef_server = Cheffish.default_chef_server)
          new_platform_spec.all_nodes.each do |server|
            platform_node_data = []
            node_array.each { |nd| platform_node_data << nd if (nd['node_name'] == server['node_name']) }
            raise "We Should Have an IP by now. Somethings Off on #{platform_node_data[0]}" unless platform_node_data[0]['ipaddress']
            _platform_node_data = platform_node_data[0]
            _node_array = node_array.flatten
            _chef_server = chef_server
            Chef::Provisioning.inline_resource(action_handler) do
              chef_node _platform_node_data['node_name'] do
                chef_server _chef_server
                remove_recipe "platform-node\\\\\\\\:\\\\\\\\:default"
                attribute ["chef_platform", "nodes"], _node_array
                attribute "platform_node", _platform_node_data
              end
            end
          end
        end

        # def ready_machines(ready_machine_spec)
        def ready_machines
          @ready_machines ||= begin
            rmb = machine_batch 'machine_batch_ready_all' do
              new_platform_spec.all_nodes.each do |server|
                machine server['node_name'] do
                  driver new_platform_spec.driver_name
                  machine_options machine_opts_for(server)
                  attribute "chef_platform", new_platform_spec.get_data
                  attribute 'chef-server', new_platform_spec.chef_server_data
                  attribute 'chef-analytics', new_platform_spec.analytics_data
                  attribute 'delivery', new_platform_spec.delivery_data
                  attribute 'supermarket', new_platform_spec.supermarket_data
                  recipe "platform-node::default"
                end
              end
              action :nothing
            end
            rmb
          end
        end

        def bootstrap_machine
          @bootstrap_machine ||= begin
            if chef_server_standalone?
              server = new_platform_spec.chef_server_nodes[0]
              rbm = machine server['node_name'] do
                driver new_platform_spec.driver_name
                machine_options machine_opts_for(server)
                attribute 'chef_platform', new_platform_spec.get_data
                attribute 'chef-server', new_platform_spec.chef_server_data
                attribute 'chef-analytics', new_platform_spec.analytics_data
                attribute 'delivery', new_platform_spec.delivery_data
                attribute 'supermarket', new_platform_spec.supermarket_data
                recipe 'platform-node::reconfigure'
                action :nothing
              end
              rbm
            else
              server = new_platform_spec.chef_server_bootstrap_backend
              rbm = machine new_platform_spec.chef_server_bootstrap_backend['node_name'] do
                driver new_platform_spec.driver_name
                machine_options machine_opts_for(new_platform_spec.chef_server_bootstrap_backend)
                attribute 'chef_platform', new_platform_spec.get_data
                attribute 'chef-server', new_platform_spec.chef_server_data
                attribute 'chef-analytics', new_platform_spec.analytics_data
                attribute 'delivery', new_platform_spec.delivery_data
                attribute 'supermarket', new_platform_spec.supermarket_data
                recipe 'platform-node::reconfigure'
                action :nothing
              end
              rbm
            end
          end
        end

        def non_bootstrap_machines
          @non_bootstrap_machines ||= begin
            nbm = machine_batch 'reconfigure_non_bootstrap' do
              new_platform_spec.all_non_bootstrap_nodes.each do |server|
                raise "We should have an IP on #{server}" unless server['ipaddress']
                machine server['node_name'] do
                  driver new_platform_spec.driver_name
                  machine_options machine_opts_for(server)
                  attribute 'chef_platform', new_platform_spec.get_data
                  attribute 'chef-server', new_platform_spec.chef_server_data
                  attribute 'chef-analytics', new_platform_spec.analytics_data
                  attribute 'delivery', new_platform_spec.delivery_data
                  attribute 'supermarket', new_platform_spec.supermarket_data
                  recipe 'platform-node::reconfigure'
                end
              end
              action :nothing
            end
            nbm
          end
        end

      end
    end
  end
end

# def remove_default_from_runlist(node_array, chef_server = Cheffish.default_chef_server)
#   new_platform_spec.all_nodes.each do |server|
#     platform_node_data = []
#     node_array.each { |nd| platform_node_data << nd if (nd['node_name'] == server['node_name']) }
#     raise "We Should Have an IP by now. Somethings Off on #{platform_node_data[0]}" unless platform_node_data[0]['ipaddress']
#     _platform_node_data = platform_node_data[0]
#     _chef_server = chef_server
#     Chef::Provisioning.inline_resource(action_handler) do
#       chef_node _platform_node_data['node_name'] do
#         chef_server _chef_server
#         remove_recipe 'platform-node'
#         remove_recipe 'platform-node\\::\\default'
#       end
#     end
#   end
# end
