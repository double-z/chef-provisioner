class Chef
  module Provisioner
    module Helpers
      require 'chef/util/file_edit'
      require 'chef/sugar/core_extensions'
      require 'chef/sugar/ip'

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

        def deep_hashify(machine_options)
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

        def self.strip_hash_nil(val)
          vvv = case val
          when Hash
            cleaned_val = val.delete_if { |kk,vv| vv.nil? }
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

        def strip_hash_nil(val)
          vvv = case val
          when Hash
            cleaned_val = val.delete_if { |kk,vv| vv.nil? }
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

    end
  end
end
