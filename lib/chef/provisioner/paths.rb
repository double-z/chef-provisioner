class Chef
  module Provisioner
    module Paths

      ##
      # Paths

      def platform_policy_group_cache_path
        ::File.join(Chef::Config[:chef_repo_path],
                    "policies", policy_group, "cache")
      end

      def remote_cache_path
        '/var/chef/cache/platform/'
      end

      def local_chef_server_cache_path
        ::File.join(platform_policy_group_cache_path, "opscode")
      end

      def local_chef_server_supermarket_path
        ::File.join(platform_policy_group_cache_path, "opscode/oc-id-applications")
      end

      def local_chef_server_rb_path
        ::File.join(local_chef_server_cache_path, "chef-server.rb")
      end

      def remote_chef_server_cache_path
        ::File.join(remote_cache_path, "opscode")
      end

      def remote_chef_server_conf_path
        "/etc/opscode"
      end

      def chef_server_files
        ['pivotal.pem', 'webui_pub.pem', 'private-chef-secrets.json', 'webui_priv.pem', 'oc-id-applications/supermarket.json']
      end

      def local_analytics_cache_path
        ::File.join(platform_policy_group_cache_path, "opscode-analytics")
      end

      def local_analytics_rb_path
        ::File.join(local_analytics_cache_path, "analytics.rb")
      end

      def remote_analytics_cache_path
        ::File.join(remote_cache_path, "opscode-analytics")
      end

      def remote_analytics_conf_path
        "/etc/opscode-analytics"
      end

      def analytics_files
        %w(actions-source.json webui_priv.pem)
      end

      def local_delivery_cache_path
        ::File.join(platform_policy_group_cache_path, "delivery")
      end

      def local_delivery_pem_path
        ::File.join(local_delivery_cache_path, "delivery.pem")
      end

      def remote_delivery_cache_path
        "/etc/chef"
      end

      def remote_delivery_conf_path
        "/etc/chef"
      end

      def remote_delivery_conf_path
        "/etc/chef"
      end

      def delivery_files
        %w(delivery.pem delivery-validator.pem)
      end

      def pkg_cache_path
        ::File.join(ENV['HOME'], ".chef/package_cache")
      end

      def packages_in_package_cache
        ar = []
        ext = new_resource.package_installer
        Dir.glob(::File.join(ENV['HOME'], ".chef/package_cache/*.#{ext}")) { |ff|
          f = ::File.basename(ff)
          ar << ff if (f.include?("opscode-reporting") ||
                       f.include?("chef-manage") ||
                       f.include?("opscode-manage") ||
                       f.include?("opscode-analytics") ||
                       f.include?("opscode-push-jobs-server") ||
                       f.include?("chef-server") ||
                       f.include?("supermarket")
                       )
        }
        ar
      end

      def pkg_files_for_service(service_name)
        case service_name
        when ('chef_server' || 'chef-server')
          files_for_chef_server if new_resource.chef_server_package_source
        when ('chef_analytics' || 'chef-analytics')
          files_for_chef_analytics if new_resource.chef_analytics_package_source
        when ('supermarket' || 'supermarket_omnibus')
          files_for_supermarket if new_resource.supermarket_package_source
        when 'delivery'
          files_for_delivery if new_resource.delivery_package_source
        else
          raise "SERVICE NOT RECOGNIZED"
        end
      end


    end
  end
end
