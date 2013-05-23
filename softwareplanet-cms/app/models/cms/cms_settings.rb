# CmsSettings

module Cms

  # Settings array:
  CMS_SETTINGS_DEFINITION = [
    'default_layout_id' => '',
    'images_path' => SOURCE_FOLDERS[SourceType::IMAGE]
  ]

  class CmsSettings < SourceSettings
    attr_accessor *CMS_SETTINGS_DEFINITION[0].keys

    def self.get_settings_definition
      CMS_SETTINGS_DEFINITION
    end

  end
end
