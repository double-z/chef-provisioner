require 'chef/util/file_edit'
require 'chef/sugar/core_extensions'
require 'chef/sugar/ip'

require_relative 'platform/coordinator.rb'
require_relative 'platform/data_handler.rb'
require_relative 'platform/file_mover.rb'
require_relative 'platform/machines.rb'
require_relative 'platform/templates.rb'

class Chef
  module Provisioner
    module Platform
    	include Coordinator
    	include DataHandler
      include Machines
      include Templates
      include FileMover
    end
  end
end
