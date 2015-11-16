class Chef
  module Provisioner
    module Platform
      class FileMover
        class Download
          include Chef::Provisioner::Paths
          include Chef::Provisioner::Platform::Coordinator

          def initialize(config = nil)

          end

          ##
          # File Download Resources

          def download_files_from_bootstrap
            download_chef_server_files
            if with_analytics?
              download_analytics_files
            end
            # if with_supermarket?
            #   download_supermarket_files
            #   upload_supermarket_files
            # end
            if with_delivery?
              download_delivery_chef_server_files
            end
          end

          def download_delivery_chef_server_files
            delivery_files.each do |delivery_file|
              delivery_file_download =  machine_file "/tmp/#{delivery_file}" do
                local_path "#{local_delivery_cache_path}/#{delivery_file}"
                if chef_server_standalone?
                  machine standalone_server_node['node_name']
                else
                  machine new_platform_spec.chef_server_bootstrap_backend['node_name']
                end
                action :nothing
              end
              delivery_file_download.run_action(:download)
            end
          end

          def download_delivery_trusted_certs
            delivery_trusted_cert = machine_file "/var/opt/delivery/nginx/ca/delivery.example.com.crt" do
              local_path "#{local_delivery_cache_path}/delivery.example.com.crt"
              machine new_platform_spec.delivery_server_node['node_name']
              action :nothing
            end
            delivery_trusted_cert.run_action(:download)
          end

          def download_chef_server_files
            chef_server_files.each do |server_file|
              chef_server_file_download = machine_file "/etc/opscode/#{server_file}" do
                local_path "#{local_chef_server_cache_path}/#{server_file}"
                if chef_server_standalone?
                  machine standalone_server_node['node_name']
                else
                  machine new_platform_spec.chef_server_bootstrap_backend['node_name']
                end
                action :nothing
              end
              chef_server_file_download.run_action(:download)
            end
          end

          def download_analytics_files
            analytics_files.each do |analytics_file|
              analytics_file_download =  machine_file "/etc/opscode-analytics/#{analytics_file}" do
                local_path "#{local_analytics_cache_path}/#{analytics_file}"
                if chef_server_standalone?
                  machine standalone_server_node['node_name']
                else
                  machine new_platform_spec.chef_server_bootstrap_backend['node_name']
                end
                action :nothing
              end
              analytics_file_download.run_action(:download)
            end
          end
        end
      end
    end
  end
