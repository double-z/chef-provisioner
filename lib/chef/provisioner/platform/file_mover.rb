require 'chef/util/file_edit'
require 'chef/sugar/core_extensions'
require 'chef/sugar/ip'
require_relative "../paths.rb"
require_relative "./coordinator.rb"

class Chef
  module Provisioner
    module Platform
      module FileMover
        include Chef::Provisioner::Paths
        include Chef::Provisioner::Platform::Coordinator

        ##
        # File Download Resources

        def download_all_files_from_bootstrap
          download_chef_server_files
          if with_analytics?
            download_analytics_files
          end
          # if with_supermarket?
          #   download_supermarket_files
          #   upload_supermarket_files
          # end
          if with_delivery?
            download_delivery_files
          end
        end

        def upload_bootsrap_files_to_non_bootstrap_nodes
          # return if chef_server_standalone_only?
          upload_chef_server_files
          upload_analytics_files if with_analytics?
          # upload_supermarket_files if with_supermarket?
          upload_delivery_files if with_delivery?
        end

        def download_chef_server_files
          # return if chef_server_standalone_only?
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

        def upload_chef_server_files
          # return if chef_server_standalone_only?
          new_platform_spec.all_non_bootstrap_nodes.each do |server|
            chef_server_files.each do |server_file|
              chef_server_file_upload = machine_file "/etc/opscode/#{server_file}" do
                local_path "#{local_chef_server_cache_path}/#{server_file}"
                machine server['node_name']
                only_if do
                  ::File.exists?("#{local_chef_server_cache_path}/#{server_file}")
                end
                action :nothing
              end
              chef_server_file_upload.run_action(:upload) # if ::File.exists?("#{local_chef_server_cache_path}/#{server_file}")
            end
          end
        end

        def download_analytics_files
          # return if chef_server_standalone_only?
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

        def upload_analytics_files
          # return if chef_server_standalone_only?
          new_platform_spec.all_non_bootstrap_nodes.each do |server|
            analytics_files.each do |analytics_file|
              analytics_file_upload =  machine_file "/etc/opscode-analytics/#{analytics_file}" do
                local_path "#{local_analytics_cache_path}/#{analytics_file}"
                machine server['node_name']
                only_if do
                  ::File.exists?("#{local_analytics_cache_path}/#{analytics_file}")
                end
                action :nothing
              end
              analytics_file_upload.run_action(:upload)
            end
          end
        end

        def download_delivery_files
          # return if chef_server_standalone_only?
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
          delivery_trusted_cert = machine_file "/var/opt/delivery/nginx/ca/delivery.example.com.crt" do
            local_path "#{local_delivery_cache_path}/delivery.example.com.crt"
            machine new_platform_spec.delivery_server_node['node_name']
            action :nothing
          end
          delivery_trusted_cert.run_action(:download)
        end

        def upload_delivery_files
          # return if chef_server_standalone_only?
          new_platform_spec.all_non_bootstrap_nodes.each do |server|
            delivery_files.each do |delivery_file|
              delivery_file_upload_etc_delivery =  machine_file "/etc/delivery/#{delivery_file}" do
                local_path "#{local_delivery_cache_path}/#{delivery_file}"
                machine server['node_name']
                only_if do
                  ::File.exists?("#{local_delivery_cache_path}/#{delivery_file}")
                end
                action :nothing
              end
              delivery_file_upload_etc_delivery.run_action(:upload)
            end
            delivery_files.each do |delivery_file|
              delivery_file_upload_etc_chef =  machine_file "/etc/chef/#{delivery_file}" do
                local_path "#{local_delivery_cache_path}/#{delivery_file}"
                machine server['node_name']
                only_if do
                  ::File.exists?("#{local_delivery_cache_path}/#{delivery_file}")
                end
                action :nothing
              end
              delivery_file_upload_etc_chef.run_action(:upload)
            end
            delivery_trusted_cert_file = machine_file "/etc/chef/trusted_certs/delivery.example.com.crt" do
              local_path "#{local_delivery_cache_path}/delivery.example.com.crt"
              machine server['node_name']
              action :nothing
            end
            delivery_trusted_cert_file.run_action(:upload)
          end
        end

        ##
        # Package File Management
        # TODO move to Chef::Provisioner::Platform::FileMover::Package(?), maybe.
        def package_files_for(server)
          path_hash_array = {}
          pkg_names = []
          case server['service']
          when "chef_server"
            pkg_names << new_resource.chef_server_package
            pkg_names << new_resource.chef_server_manage_package if (new_resource.with_manage &&
                                                                     (server['role'] == "frontend"))
            pkg_names << new_resource.chef_server_reporting_package if new_resource.with_reporting
          when "analytics"
            pkg_names << new_resource.analytics_package
          when "supermarket"
            pkg_names << new_resource.supermarket_package
          when "delivery"
            pkg_names << new_resource.delivery_package
          end
          pkg_names.each do |pkg_name|
            pkg_file_path = ::File.join(pkg_cache_path, pkg_name)
            path_hash_array << {pkg_file_path => "/var/chef/cache/#{pkg_name}"}
          end
        end

        def package_files_path_for_analytics
          pkg_file_path = ::File.join(pkg_cache_path, analytics_pkg_name)
          path_hash = {pkg_file_path => "/var/chef/cache/#{pkg_name}"}
        end

        def package_files_path_for_supermarket
          pkg_file_path = ::File.join(pkg_cache_path, analytics_pkg_name)
          path_hash = {pkg_file_path => "/var/chef/cache/#{pkg_name}"}
        end

        def package_files_path_for_delivery
          pkg_file_path = ::File.join(pkg_cache_path, analytics_pkg_name)
          path_hash = {pkg_file_path => "/var/chef/cache/#{pkg_name}"}
        end

        def upload_chef_server_packages_from_package_cache
          new_platform_spec.chef_server_nodes.each do |server|
            chef_server_packages.each do |pkg_name|
              pkg_cache_path = ::File.join(ENV['HOME'], ".chef/package_cache")
              pkg_file_path = ::File.join(pkg_cache_path, pkg_name)
              package_file_upload = machine_file "/var/chef/cache/#{pkg_name}" do
                local_path pkg_file_path
                machine server['node_name']
                # only_if do
                #   ::File.exists?("#{local_chef_server_cache_path}/#{server_file}")
                # end
                action :nothing
              end
              package_file_upload.run_action(:upload) # if ::File.exists?("#{local_chef_server_cache_path}/#{server_file}")
            end
          end
        end

        def upload_packages_from_package_cache
          new_platform_spec.all_nodes.each do |server|
            packages_in_package_cache.each do |pkg_file_path|
              server_file = ::File.basename(pkg_file_path)
              package_file_upload = machine_file "/var/chef/cache/#{server_file}" do
                local_path pkg_file_path
                machine server['node_name']
                # only_if do
                #   ::File.exists?("#{local_chef_server_cache_path}/#{server_file}")
                # end
                action :nothing
              end
              package_file_upload.run_action(:upload) # if ::File.exists?("#{local_chef_server_cache_path}/#{server_file}")
            end
          end
        end

      end
    end
  end
end
