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
          if !s.nil? && s.filename==source_name
            files.push(s)
          end
        end
        files
      end

      def quick_get_layout_name_by_id(layout_id)
        layout_id.gsub(/pre(1|8)-id-/, '')
      end

      def quick_build_seo_with_path(layout_id)
        page_name = layout_id.gsub('pre1-id-', '')
        seo = Source.quick_attach(SourceType::LAYOUT, page_name, SourceType::SEO)
        path = seo.get_source_folder + seo.name
        [seo, path]
      end

      def quick_search(type,  name)
        ext =  SOURCE_TYPE_EXTENSIONS[type.to_i]
        Source.new({ :type => type, :name => name, :extension => ext, :data => nil })
      end

      def quick_attach(type, name, attach_type)
        ext =  SOURCE_TYPE_EXTENSIONS[attach_type.to_i]
        attach_name = type.to_s + Cms::TARGET_DIVIDER + name
        Source.new({ :type => attach_type, :name => attach_name, :extension => ext, :data => nil })
      end

      def quick_attach_short_path(type, name, attach_type)
        attach_name = type.to_s + Cms::TARGET_DIVIDER + name
        if attach_type == SourceType::CSS
          return CUSTOM_SCSS_FOLDER + attach_name
        end
        raise "oops for other types"
      end

      def quick_content_search(content_name, content_type)
        ext = ""
        Source.new({ :type => content_type, :name => content_name, :extension => ext, :data => nil })
      end

    end; extend ClassMethods
  end
end