require_relative './machine_options/ssh.rb'
require_relative './machine_options/vagrant.rb'

class Chef
  module Provisioner
    module MachineOptions

      ##
      # Machine Options

      def machine_opts_for(server)
        case new_platform_spec.driver_name
        when "ssh"
          ssh_machine_opts_for(server)
        when "vagrant"
          vagrant_machine_opts_for(server)
        when "docker"
          raise "Docker Driver Not Yet Implemented"
        when "aws"
          raise "Aws Driver Not Yet Implemented"
        when "lxc"
          raise "LXC Driver Not Yet Implemented"
        end
      end

      def vagrant_machine_opts_for(server)
        m = Chef::Provisioner::MachineOptions::Vagrant.generate_config(server)
        m
      end

      def ssh_machine_opts_for(server)
        m = Chef::Provisioner::MachineOptions::Ssh.generate_config(server)
        m
      end

    end
  end
end
