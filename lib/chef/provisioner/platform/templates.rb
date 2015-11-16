class Chef
  module Provisioner
    module Platform
      module Templates

        def create_or_delete_directory(action, path)
          d = ::Chef::Resource::Directory.new(path, run_context)
          d.recursive(true)
          if new_resource.action == :destroy_all
            d.run_action(:delete)
          else
            d.run_action(action.to_sym) unless ((action.to_sym == :create) &&
                                                ::File.exists?(path))
          end
        end


        def analytics_rb_template
          @analytics_rb_template ||= begin
            arbt = ::Chef::Resource::Template.new(local_analytics_rb_path,
                                                  run_context)
            arbt.source("analytics.rb.erb")
            arbt.mode("0644")
            arbt.cookbook("chef-platform-provision")
            arbt.variables(
              :chef_analytics => new_platform_spec.analytics_data,
              :analytics_node_name => new_resource.analytics_api_fqdn
            )
            arbt
          end
        end

        def chef_server_rb_template
          @chef_server_rb_template ||= begin
            csrt = ::Chef::Resource::Template.new(local_chef_server_rb_path,
                                                  run_context)
            csrt.source("chef-server.rb.erb")
            csrt.mode("0644")
            csrt.cookbook("chef-platform-provision")
            csrt.variables(
              :chef_servers => new_platform_spec.chef_server_nodes,
              :chef_server_config => new_platform_spec.chef_server_config,
              :chef_server_data => new_platform_spec.chef_server_data,
              :analytics_data => new_platform_spec.analytics_data
            )
            csrt
          end
        end

      end
    end
  end
end
