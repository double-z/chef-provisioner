class Chef
  module Provisioner
    module Helpers
      def self.deep_hashify(machine_options)
        if machine_options.respond_to?(:to_hash)
          hash = machine_options.to_hash

          hash.inject({}){|result, (key, value)|
            if value.respond_to?(:to_hash)
              new_value = deep_hashify(value)
            else
              new_value = value
            end
            result[key] = new_value
            result
          }
        end
      end
    end
  end
end
