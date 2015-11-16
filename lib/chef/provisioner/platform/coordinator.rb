require 'chef/util/file_edit'
require 'chef/sugar/core_extensions'
require 'chef/sugar/ip'

class Chef
  module Provisioner
    module Platform

      module Coordinator
        ####
        #
        # Top level Checks

        # Check if should run
        def should_run?
          val = (!all_nodes_ready? ||
                 config_updated?)
        end

        # Check all configs
        ####
        #
        # Check Config Equalities
        def platform_configuration_updated?
          config_updated?
        end

        def config_updated?
          current_hash = strip_hash_nil(deep_hashify(current_platform_spec.get_data))
          new_hash = strip_hash_nil(deep_hashify(new_platform_spec.get_data))
          # puts "NEW ALLC#{new_hash}" # #{new_platform_spec.inspect}"
          # puts "CURRENT ALLC#{current_hash}" # #{current_platform_spec.inspect}"
          if ((current_hash && current_hash.empty?) &&
              (new_hash && new_hash.empty?))
            val = true
          else
            val = current_hash.eql?(new_hash)
          end
          ret_val = val ? false : true
          # puts "NEWCONF #{ret_val.to_s}"
          ret_val
        end

        # def config_updated?
        #   val = (chef_server_config_updated? ||
        #          analytics_config_updated?)
        # end

        # Check if all nodes are ready
        def all_nodes_ready?
          if (current_platform_spec.all_nodes.nil? ||
              current_platform_spec.all_nodes.empty?)
            false
          else
            true
          end
        end

        def with_analytics?
          if new_resource.analytics_api_fqdn
            true
          else
            false
          end
        end

        def with_supermarket?
          if new_resource.supermarket_api_fqdn
            true
          else
            false
          end
        end

        def with_delivery?
          if new_resource.delivery_api_fqdn
            true
          else
            false
          end
        end

        def chef_server_standalone?
          if new_resource.chef_server_topology == "standalone"
            true
          else
            false
          end
        end

        def chef_server_standalone_only?
          if (chef_server_standalone? &&
              !with_analytics?)
            true
          else
            false
          end
        end

        ##
        # Returns all ready nodes

        def all_ready_nodes
          current_platform_spec.all_nodes
        end

        def reconfigure_action
          all_nodes_ready? ? :converge : :converge_only
        end

        def standalone_server_node
          server = new_platform_spec.chef_server_nodes[0]
          server
        end

        def chef_server_config_updated?
          current_hash = strip_hash_nil(deep_hashify(current_platform_spec.chef_server_data))
          new_hash = strip_hash_nil(deep_hashify(new_platform_spec.chef_server_data))
          # puts "NEW #{new_hash}"
          # puts "CURRENT #{current_hash}"
          if ((current_hash && current_hash.empty?) &&
              (new_hash && new_hash.empty?))
            val = true
          else
            val = current_hash.eql?(new_hash)
          end
          ret_val = val ? false : true
          ret_val
        end

        def analytics_config_updated?
          current_hash = strip_hash_nil(deep_hashify(current_platform_spec.analytics_data))
          new_hash = strip_hash_nil(new_platform_spec.analytics_data)
          # puts "NEWAA #{new_hash}"
          # puts "CURRENTAA #{current_hash}"
          if ((current_hash && current_hash.empty?) &&
              (new_hash && new_hash.empty?))
            val = true
          else
            val = current_hash.eql?(new_hash)
          end
          ret_val = val ? false : true
          # puts "ACFG #{ret_val.to_s}"
          ret_val
        end

        def supermarket_config_updated?
          current_hash = strip_hash_nil(deep_hashify(current_platform_spec.supermarket_data))
          new_hash = strip_hash_nil(deep_hashify(new_platform_spec.supermarket_data))
          if ((current_hash && current_hash.empty?) &&
              (new_hash && new_hash.empty?))
            val = true
          else
            val = current_hash.eql?(new_hash)
          end
          ret_val = val ? false : true
          ret_val
        end

        def delivery_config_updated?
          current_hash = strip_hash_nil(deep_hashify(current_platform_spec.delivery_data))
          new_hash = strip_hash_nil(deep_hashify(new_platform_spec.delivery_data))
          if ((current_hash && current_hash.empty?) &&
              (new_hash && new_hash.empty?))
            val = true
          else
            val = current_hash.eql?(new_hash)
          end
          ret_val = val ? false : true
          ret_val
        end
      end
    end
  end
end
