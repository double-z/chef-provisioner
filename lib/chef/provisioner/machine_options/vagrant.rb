require 'chef/provisioning/vagrant_driver'

class Chef
  module Provisioner
    module MachineOptions
      class Vagrant

        def self.generate_config(server)
          local_provisioner_options = {
            :vagrant_options => {
              'vm.box' => "opscode-ubuntu-12.04" # ,
              # 'vm.box_url' => attr['harness']['vagrant']['box_url']
            },
            :vagrant_config => generate_vagrant_config(server)
          }
        end

        def self.generate_vagrant_config(server)
          # Vagrant/Virtualbox notes:
          # * it sucks that you have to hardcode "IDE Controller", recent opscode
          #   packer images switched to IDE, but we can't easily detect SATA
          # * virtio network interfaces, in some circumstances, provide MUCH WORSE
          #   performance than good ol' e1000 (the default)
          # * What's the point of the "nonrotational" flag?  tells you the underlying
          #   disk is an SSD.  This should be fine for most of our recent Macs, but I'm
          #   not sure if there's any actual benefit for ext4

          vagrant_config = <<-ENDCONFIG
          config.vm.network 'private_network', ip: "#{server['machine_options_ipaddress']}"
          config.vm.hostname = "#{server['node_name']}"
          config.vm.provider 'virtualbox' do |v|
            v.customize [
              'modifyvm', :id,
              '--name', "#{server['node_name']}",
              '--memory', "256",
              '--cpus', "1",
              '--natdnshostresolver1', 'on',
              '--usb', 'off',
              '--usbehci', 'off'
            ]
          end
          ENDCONFIG
          vagrant_config
        end

      end
    end
  end
end
