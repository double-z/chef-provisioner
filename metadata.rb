name 'chef-provisioner'
maintainer 'Zack Zondlo'
maintainer_email 'zackzondlo@gmail.com'
license 'all_rights'
description 'Installs/Configures chef-provisioner'
license          'Apache 2.0'
long_description <<-EOH
Chef Provisioner provisions the Chef Platform using chef-provisioning.
EOH
require          File.expand_path('../lib/chef/provisioner/version', __FILE__)
version          Chef::Provisioner::VERSION