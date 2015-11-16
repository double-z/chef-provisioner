require 'chef/util/file_edit'
require 'chef/sugar/core_extensions'
require 'chef/sugar/ip'
require_relative 'coordinator.rb'

class Chef
  module Provisioner
    module Platform
      module ConfigHandler
        include Coordinator

        ##
        # New Platform Data
        def new_platform_data
          data = {}
          data['policygroup'] = new_resource.name
          data['driver'] = {}
          data['chef_server'] = {}
          data['analytics'] = {}
          data['supermarket'] = {}
          data['delivery'] = {}
          data['driver']['name'] = new_resource.driver_name
          data['chef_server']['version'] = new_resource.chef_server_version
          data['chef_server']['package_source'] = new_resource.chef_server_package_source
          data['chef_server']['topology'] = new_resource.chef_server_topology
          data['chef_server']['api_fqdn'] = new_resource.chef_server_api_fqdn
          data['chef_server']['configuration'] = new_resource.chef_server_configuration
          data['analytics']['version'] = new_resource.analytics_version
          data['analytics']['api_fqdn'] = new_resource.analytics_api_fqdn
          data['analytics']['configuration'] = new_resource.analytics_configuration
          data['supermarket']['version'] = new_resource.supermarket_version
          data['supermarket']['api_fqdn'] = new_resource.supermarket_api_fqdn
          data['supermarket']['configuration'] = new_resource.supermarket_configuration
          data['delivery']['version'] = new_resource.delivery_version
          data['delivery']['api_fqdn'] = new_resource.delivery_api_fqdn
          data['delivery']['configuration'] = new_resource.delivery_configuration
          if (current_platform_spec.all_nodes &&
              !current_platform_spec.all_nodes.nil? &&
              current_platform_spec.all_nodes.kind_of?(Array)
              !current_platform_spec.all_nodes.empty?)
            data['nodes'] = current_platform_spec.all_nodes
          else
            data['nodes'] = new_resource.nodes if new_resource.nodes
          end
          # _data = Chef::Provisioner::Helpers.deep_hashify(data)
          # ndata = {}
          ndata = data
          # # puts ndata.to_yaml
          # puts JSON.pretty_generate(ndata)
          ndata
        end

        def use_platform_data(new_conf, current_conf)
          data = {}
          data['policygroup'] = new_resource.name
          data['driver'] = {}
          data['chef_server'] = {}
          data['analytics'] = {}
          data['supermarket'] = {}
          data['delivery'] = {}
          data['driver']['name'] = current_conf['driver_name']
          data['chef_server']['version'] = new_conf.chef_server_version
          data['chef_server']['package_source'] = new_conf.chef_server_package_source
          data['chef_server']['topology'] = current_conf['topology']
          data['chef_server']['api_fqdn'] = new_conf['chef_server']_api_fqdn
          data['chef_server']['configuration'] = new_conf['chef_server']['configuration']
          data['analytics']['version'] = new_conf['analytics_version']
          data['analytics']['api_fqdn'] = new_conf.analytics_api_fqdn
          data['analytics']['configuration'] = new_conf.analytics_configuration
          data['supermarket']['version'] = new_conf.supermarket_version
          data['supermarket']['api_fqdn'] = new_conf.supermarket_api_fqdn
          data['supermarket']['configuration'] = new_conf.supermarket_configuration
          data['delivery']['version'] = new_conf.delivery_version
          data['delivery']['api_fqdn'] = new_conf.delivery_api_fqdn
          data['delivery']['configuration'] = new_conf.delivery_configuration
          data['nodes'] = new_resource.nodes if new_resource.nodes
          # _data = Chef::Provisioner::Helpers.deep_hashify(data)
          # ndata = {}
          ndata = data
          # # puts ndata.to_yaml
          # puts JSON.pretty_generate(ndata)
          ndata
        end

        def generate_node_array(resource)
          nr = []
          nr << chef_server_node_array(resource)
          nr << analytics_node_array(resource) if with_analytics?
          nr << supermarket_node_array(resource) if with_supermarket?
          nr << delivery_node_array(resource) if with_delivery?
          nr.flatten
        end

        def chef_server_node_array(resource)
          csna = []

          csna
        end

        def analytics_node_array(resource)
          ana = []
          ana
        end

        def supermarket_node_array(resource)
          sna = []
          sna
        end

        def delivery_node_array(resource)
          dna = []
          dna
        end

        def deep_hashify(machine_options)
          if machine_options.respond_to?(:to_hash)
            hash = machine_options.to_hash

            hash.inject({}){|result, (key, value)|
              if value.respond_to?(:to_hash)
                new_value = deep_hashify(value)
              else
                new_value = value
              end
              result[key] = new_value
              result
            }
          end
        end

        def strip_hash_nil(val)
          vvv = case val
          when Hash
            cleaned_val = val.delete_if { |kk,vv| vv.nil? }
            cleaned_val.each do |k,v|
              case v
              when Hash
                strip_hash_nil(v)
              when Array
                v.flatten!
                v.uniq!
              end
            end
          end
          vvv
        end


      end
    end
  end
end
