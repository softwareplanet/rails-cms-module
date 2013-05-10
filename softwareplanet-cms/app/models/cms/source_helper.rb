# Methods:

#   get_source_settings       # <= layout source settings
#   get_source_seo            # <= layout source seo tags
#   read_seo_values           # <= hash seo tags

#   create_default_settings
#   create_default_seo

module Cms
  module SourceHelper

    module ClassMethods
      # For nested layouts structure.
      # If parent is empty, layout became a top-level.
      def reorganize_by_ids(source_id, parent_id)
        source = Source.get_source_by_id(source_id)
        source.detach
        parent = Source.find_by_id(parent_id) unless parent_id.to_s.length == 0
        source.attach_to(parent) if parent
        source
      end
      # Read source settings from settings file
      # If settings file not exists, it will be created with default settings
      def get_source_settings(source_id)
        source = Source.get_source_by_id(source_id)
        settings = source.get_source_attach(SourceType::SETTINGS)
        settings = source.create_default_settings if settings.nil?
        SourceSettings.new.parse(settings)
      end

      def get_source_seo(source_id)
        source = Source.get_source_by_id(source_id)
        seo = source.get_source_attach(SourceType::SEO)
        seo = source.create_default_seo if seo.nil?
        SourceSEO.new.parse(seo)
      end

      def read_seo_values(seo_source)
        hash = {}
        File.open(seo_source.get_source_filepath, "r").each_line  do |line|
          line = line.downcase()
          if line.slice('title')
            str1 = "<title>"
            str2 = "</title>"
            hash['title'] = line[line.index(str1) + str1.size .. line.index(str2)-1]
          end
          if line.slice('keywords')
            str = "<meta name='keywords' content='"
            hash['keywords'] = line[line.index(str) + str.size .. -5]
          end
          if line.slice('description')
            str = "<meta name='description' content='"
            hash['description'] = line[line.index(str) + str.size .. -4]
          end
        end
        hash
      end
    end

    def create_default_settings
      Source.build(:type => SourceType::SETTINGS, :name => self.get_source_name, :data => SourceSettings.default_settings.to_s, :target => self)
    end

    def create_default_seo
      Source.build(:type => SourceType::SEO, :name => self.get_source_name, :data => SourceSEO.default_seo, :target => self)
    end

  extend ClassMethods
  end
end