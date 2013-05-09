require 'yaml'

module Cms
    SETTINGS_DEFINITION = [
      :publish => '1',
      :display => '1'

    ]
    class SourceSettings
      attr_accessor *SETTINGS_DEFINITION[0].keys

      def parse(settings_source)
        settings_source.load!
        result = YAML.load(settings_source.data)
        SETTINGS_DEFINITION[0].map{ |n, v|
          send("#{n}=", result[n])
        }
        self
      end

      def self.default_settings
        SETTINGS_DEFINITION[0].to_yaml
      end
      def get_data
        hash = Hash.new
        self.instance_variables.each {|var| hash[var.to_s.delete("@")] = self.instance_variable_get(var).to_s }
        hash.to_yaml
      end
    end

end
