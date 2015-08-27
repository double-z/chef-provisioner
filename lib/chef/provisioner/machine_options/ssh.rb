require 'chef/provisioning/ssh_driver'

class Chef
  module Provisioner
    module MachineOptions
      class Ssh

        def self.generate_config(server)
          local_provisioner_options = {
            :transport_options => {
              'ip_address' => server['machine_options_ipaddress'],
              'username' => 'vagrant',
              'ssh_options' => {
                'password' => 'vagrant'
              }
            }
          }
        end

      end
    end
  end
end
