# Search Accelerator
# Methods:
#   find_source_by_name_and_type  # <= quick search by name and type

module Cms
  module SourceSearchAccelerator
    module ClassMethods

      # CMS quick default swettings:
      def get_cms_settings_file_turbo
        cms_config_file = "#{SOURCE_FOLDERS[SourceType::CMS_SETTINGS]}/default"
        if File.exists?(cms_config_file)
          source = Source.new(:type => SourceType::CMS_SETTINGS, :name => 'default', :data => File.read(cms_config_file))
        else
          source = Source.build(:type => SourceType::CMS_SETTINGS, :name => 'default', :data => CmsSettings.default_settings.to_s)
        end
        source
      end

      def find_source_by_name_and_type(source_name, source_type)
        files = Array.new
        dir = AdapterStable.get_source_folder(source_type)
        Dir.glob(dir+"**/*"+source_name).each do |f|
          s = build_source(f, source_type)
          files.push(s) unless s.nil?
        end
        files
      end

    end; extend ClassMethods
  end
end