#
# Cookbook Name:: chef-provisioner
# Recipe:: destroy_all
#

chef_platform_provision "prod" do
  action :destroy_all
end