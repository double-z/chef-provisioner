#
# Cookbook Name:: chef-provisioner
# Recipe:: default
#

gem_version = run_context.cookbook_collection[cookbook_name].metadata.version

if Chef::Resource::ChefGem.instance_methods(false).include?(:compile_time)
  chef_gem 'chef-provisioner' do
    version gem_version
    compile_time true
  end
else
  chef_gem 'chef-provisioner' do
    version gem_version
    action :nothing
  end.run_action(:install)
end

require 'chef/provisioner'