require 'yaml'

module Cms
    SETTINGS_DEFINITION = [
      :PUBLISH => '1',
      :DISPLAY => '1'

    ]
    class SourceSettings
      attr_accessor *SETTINGS_DEFINITION[0].keys

      def parse(settings_source)
        settings_source.load!
        settings_source.data
        result = YAML.load(settings_source.data)
        @PUBLISH = result[:PUBLISH]
        @DISPLAY = result[:DISPLAY]
        self
      end

      def self.default_settings
        SETTINGS_DEFINITION[0].to_yaml
      end
    end

end
