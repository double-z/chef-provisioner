require 'cheffish'
require 'chef/provisioning'
require 'chef/provisioner/platform_spec'

#
# Specification for a platform. Sufficient information to find and contact it
# after it has been set up.
#
class Chef
  module Provisioner
    class ChefPlatformSpec < PlatformSpec

      def initialize(platform_data)
        super(platform_data)
      end

      def self.current_spec(policy_group)
        new_platform_data = Hash.new
        val = (self.get(policy_group) || self.new_entry(new_platform_data))
        val
      end

      def self.new_spec(policy_group, platform_data)
        use_new_config = strip_hash_nil(platform_data)
        val = self.new_entry(use_platform_data)
        val
      end

      def self.get(policy_group)
        chef_server = Cheffish.default_chef_server
        chef_api = Cheffish.chef_server_api(chef_server)
        begin
          platform_data = chef_api.get("/data/#{policy_group}/chef_platform")
          platform_data.delete('id') if platform_data['id']
          get = ChefPlatformSpec.new(platform_data)
        rescue Net::HTTPServerException => e
          if e.response.code == '404'
            return nil
          else
            raise
          end
        end
      end

      # Creates PlatformSpec with the given platform_data
      def self.new_entry(platform_data)
        ChefPlatformSpec.new(platform_data)
      end

      def get
        begin
          if self.platform_data
            self.platform_data
          end
        rescue
        end
      end

      ##
      #
      # all_nodes Specs
      #
      def all_nodes
        begin
          if self.platform_data && self.platform_data['nodes']
            self.platform_data['nodes']
          end
        rescue
        end
      end

      ##
      #
      # chef_server Specs
      #
      def chef_server_nodes
        @chef_server_nodes ||= begin
          chef_servers = []
          if self.platform_data && self.platform_data['nodes']
            self.platform_data['nodes'].each do |node_data|
              chef_servers << node_data if node_data['service'] == "chef_server"
            end
            chef_servers
          end
        end
      end

      def chef_server_non_bootstrap_nodes
        @chef_server_non_bootstrap_nodes ||= begin
          non_bootstrap = []
          chef_server_nodes.each do |node_data|
            non_bootstrap << node_data if node_data['bootstrap'] == false
          end
          non_bootstrap
        end
      end

      def chef_server_bootstrap_backend
        @chef_server_bootstrap_backend ||= begin
          bootstrap_backend = ""
          chef_server_nodes.each do |node_data|
            bootstrap_backend = node_data if (node_data['role'] == "backend" && node_data['bootstrap'] == true)
          end
          bootstrap_backend
        end
      end

      def chef_server_secondary_backend
        @chef_server_secondary_backend ||= begin
          secondary_backend = ""
          chef_server_nodes.each do |node_data|
            secondary_backend = node_data if (node_data['role'] == "backend" && node_data['bootstrap'] == false)
          end
          secondary_backend
        end
      end

      def chef_server_frontend_nodes
        @chef_server_frontend_nodes ||= begin
          frontend_nodes = []
          chef_server_nodes.each do |node_data|
            frontend_nodes << node_data if node_data['role'] == "frontend"
          end
          frontend_nodes
        end
      end

      def chef_server_backend_nodes
        @chef_server_backend_nodes ||= begin
          backend_nodes = []
          chef_server_nodes.each do |node_data|
            backend_nodes << node_data if node_data['role'] == "backend"
          end
          backend_nodes
        end
      end

      def is_chef_server?(server)
        chefservers = []
        chef_server_nodes.each do |server_data|
          chefservers << server['node_name'] if (server['node_name'] == server_data['node_name'])
        end
        val = (chefservers.empty?) ? false : true
        val
      end

      def is_bootstrap_backend?(server)
        chef_server_bootstrap_backend["node_name"] == server['node_name']
      end

      def is_secondary_backend?(server)
        chef_server_secondary_backend["node_name"] == server['node_name']
      end

      def is_backend?(server)
        backends = []
        chef_server_backend_nodes.each do |server_data|
          backends << server['node_name'] if (server['node_name'] == server_data['node_name'])
        end
        val = (backends.empty?) ? false : true
        val
      end

      def is_frontend?(server)
        frontends = []
        chef_server_frontend_nodes.each do |server_data|
          frontends << server['node_name'] if (server['node_name'] == server_data['node_name'])
        end
        val = (frontends.empty?) ? false : true
        val
      end

      def chef_server_data
        self.platform_data['chef_server']
      end

      def chef_server_config
        self.platform_data['chef_server']['configuration'] rescue {}
      end

      ##
      #
      # Analytics Specs
      #
      def analytics_nodes
        @analytics_nodes ||= begin
          analytics_servers = []
          if self.platform_data && self.platform_data['nodes']
            self.platform_data['nodes'].each do |node_data|
              analytics_servers << node_data if node_data['service'] == "analytics"
            end
            analytics_servers
          end
        end
      end

      def is_analytics?(server)
        analytics_nodes[0]["node_name"] == server['node_name']
      end

      def analytics_data
        self.platform_data['analytics']
      end

      def analytics_config
        self.platform_data['analytics']['configuration'] rescue {}
      end

      ##
      #
      # supermarket Specs
      #
      def supermarket_nodes
        @supermarket_nodes ||= begin
          supermarket_servers = []
          if self.platform_data && self.platform_data['nodes']
            self.platform_data['nodes'].each do |node_data|
              supermarket_servers << node_data if node_data['service'] == "supermarket"
            end
            supermarket_servers
          end
        end
      end

      def is_supermarket?(server)
        supermarket_nodes[0]["node_name"] == server['node_name'] unless supermarket_nodes.empty?
      end

      def supermarket_config
        self.platform_data['supermarket']['configuration']
      end

      ##
      #
      # delivery Specs
      #
      def delivery_nodes
        @delivery_nodes ||= begin
          deliverys = []
          if self.platform_data && self.platform_data['nodes']
            self.platform_data['nodes'].each do |node_data|
              deliverys << node_data if node_data['service'] == "delivery"
            end
            deliverys
          end
        end
      end

      def delivery_server_node
        @delivery_server_node ||= begin
          delivery_server = ""
          delivery_nodes.each do |node_data|
            delivery_server = node_data if (node_data['role'] == "delivery_server")
          end
          delivery_server
        end
      end

      def delivery_build_nodes
        @delivery_build_nodes ||= begin
          delivery_build_nodes = []
          delivery_nodes.each do |node_data|
            delivery_build_nodes << node_data if node_data['role'] == "delivery_build"
          end
          delivery_build_nodes
        end
      end

      def is_delivery?(server)
        chefservers = []
        delivery_nodes.each do |server_data|
          chefservers << server['node_name'] if (server['node_name'] == server_data['node_name'])
        end
        val = (chefservers.empty?) ? false : true
        val
      end

      def is_delivery_server?(server)
        delivery_server_node["node_name"] == server['node_name']
      end

      def is_delivery_build?(server)
        backends = []
        delivery_build_nodes.each do |server_data|
          backends << server['node_name'] if (server['node_name'] == server_data['node_name'])
        end
        val = (backends.empty?) ? false : true
        val
      end

      def delivery_config
        self.platform_data['delivery']['configuration']
      end

      def get_status
        begin
          if self.platform_data
            _self_platform_data = self.platform_data
            return _self_platform_data['status']
          end
        rescue
        end
      end

      #
      # Globally unique identifier for this platform. Does not depend on the platform's
      # location or existence.
      #
      def id
        ChefPlatformSpec.id_from(chef_server, name)
      end

      def self.id_from(chef_server, name)
        "#{chef_server[:chef_server_url]}/data/platform/#{name}"
      end

      def save_data_bag(action_handler)
        _self = self
        _self_platform_data = stringify_keys(_self.platform_data)
        # _chef_server = _self.chef_server
        _chef_server = Cheffish.default_chef_server
        ChefMetal.inline_resource(action_handler) do
          chef_data_bag_item "chef_platform" do
            action :create
            data_bag 'prod'
            chef_server _chef_server
            raw_data _self.platform_data
          end
        end
      end

      def delete_data_bag_item_entry(action_handler)
        _self = self
        _chef_server = Cheffish.default_chef_server
        ChefMetal.inline_resource(action_handler) do
          chef_data_bag_item "chef_platform" do
            data_bag 'prod'
            chef_server _chef_server
            action :delete
          end
        end
      end

      def delete(action_handler)
        delete_data_bag_item_entry(action_handler)
      end

      def save(action_handler)
        save_data_bag(action_handler)
      end

      def mark_matched_platform_file_taken(matched_platform_file)
        content = JSON.parse(File.read(matched_platform_file))
        content.merge!({ "status" => "allocated"})
        ::File.open(matched_platform_file,"w") do |new_json|
          new_json.puts ::JSON.pretty_generate(JSON.parse(content.to_json))
        end
      end

      def strip_hash_nil(val)
        vvv = case val
        when Hash
          cleaned_val = val.delete_if { |kk,vv| vv.nil? || (vv && vv.is_a?(String) && vv.empty?) }
          cleaned_val.each do |k,v|
            case v
            when Hash
              strip_hash_nil(v)
            when Array
              v.flatten!
              v.uniq!
            end
          end
        end
        vvv
      end

      protected

      attr_reader :chef_server

      #
      # Chef API object for the given Chef server
      #
      def self.chef_api
        Cheffish.server_api_for(chef_server)
      end

      def self.strip_hash_nil(val)
        vvv = case val
        when Hash
          cleaned_val = val.delete_if { |kk,vv| vv.nil? || (vv && vv.is_a?(String) && vv.empty?) }
          cleaned_val.each do |k,v|
            case v
            when Hash
              strip_hash_nil(v)
            when Array
              v.flatten!
              v.uniq!
            end
          end
        end
        vvv
      end

      def self.stringify_keys(hash)
        hash.inject({}){|result, (key, value)|
          new_key   = case key
          when Symbol
            key.to_s
          else
            key
          end

          new_value = case value
          when Hash
            stringify_keys(value)
          when String
            value
          else
            value
          end

          result[new_key] = new_value
          result
        }
      end

      def stringify_keys(hash)
        hash.inject({}){|result, (key, value)|
          new_key   = case key
          when Symbol
            key.to_s
          else
            key
          end

          new_value = case value
          when Hash
            stringify_keys(value)
          when String
            value
          else
            value
          end

          result[new_key] = new_value
          result
        }
      end

    end
  end
end