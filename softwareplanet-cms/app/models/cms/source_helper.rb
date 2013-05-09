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
    end

    def create_default_settings
      Source.build(:type => SourceType::SETTINGS, :name => self.get_source_name, :data => SourceSettings.default_settings.to_s, :target => self)
    end


  extend ClassMethods
  end
end