# SourceSettings - builder class, with dynamic list of attributes, specified in SETTINGS_DEFINITION array.
# You can add any new items to SETTINGS_DEFINITION array, and they will be automatically included as class accessors methods.
# Later,

# Methods definition:
#
#   parse                    # <= parse source settings
#   self.default_settings    # <= default settings to yaml format
#   get_data                 # <= source settings to yaml format


require 'yaml'

module Cms

  # Settings array:
  LAYOUT_SETTINGS_DEFINITION = [
    'no_publish' => '1',
    'no_show' => '1',
    'title' => '',
    'keywords' => '',
    'description' => ''
  ]

  class SourceSettings
    attr_accessor *LAYOUT_SETTINGS_DEFINITION[0].keys

    def self.get_settings_definition
      LAYOUT_SETTINGS_DEFINITION
    end

    def self.default_settings
      self.get_settings_definition[0].to_yaml
    end

    # Get settings in yml format
    def get_data_yml
      hash = {}
      self.instance_variables.each {|key| hash[key.to_s.delete("@")] = self.instance_variable_get(key).to_s }
      hash.to_yaml
    end

    def get_data_hash
      hash = {}
      self.class.get_settings_definition[0].map{ |n, v|
        attr = send("#{n}")
        hash[n] = attr
      }
      hash
    end

    # Elect only those parameters, that correspond to SETTINGS_DEFINITION
    def elect_params(params)
      params.each do |k, v|
        send("#{k}=", v) if self.class.get_settings_definition[0].include?(k)
      end
      self
    end

    # Reads settings from `source` settings file and populate self instance variables
    def read_source_settings(source)
      source.load!
      result = YAML.load(source.data)
      self.class.get_settings_definition[0].map{ |n, v|
        send("#{n}=", result[n])
      }
      self
    end

    # Write own settings variables to settings file, specified in `source`
    def write_source_settings(source)
      source.set_data(get_data_hash.to_yaml)
    end
  end
end
