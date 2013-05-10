# Methods:

#   parse                 # <= parse source settings
#   default_settings      # <= default settings to yaml format
#   get_data              # <= source settings to yaml format

require 'yaml'

module Cms
    SETTINGS_DEFINITION = [
      'publish' => '1',
      'display' => '1'
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
        hash = {}
        self.instance_variables.each {|key| hash[key.to_s.delete("@")] = self.instance_variable_get(key).to_s }
        hash.to_yaml
      end
    end

end
