require "image_size"

module Cms
  require 'ostruct'
  require_relative 'source_settings'
  require_relative 'cms_settings'
  require_relative 'source_helper'
  require_relative 'source_gallery_helper'
  require_relative 'adapter_stable'
  require_relative 'source_compiler'
  require_relative 'adapter_stable_aliases'
  require_relative 'source_search_accelerator'

  class Source < OpenStruct

    include AdapterStable
    extend AdapterStable::ClassMethods
    include AdapterStableAliases
    extend AdapterStableAliases::ClassMethods
    include SourceHelper
    extend SourceHelper::ClassMethods
    include SourceGalleryHelper
    extend SourceGalleryHelper::ClassMethods
    include SourceCompiler
    extend SourceCompiler::ClassMethods
    include SourceSearchAccelerator
    extend SourceSearchAccelerator::ClassMethods

    #
    # Images stored in public folder, so we can remove it from link image url
    #
    def get_image_path
      get_source_filepath.gsub('public', '')
    end

    #
    # ImageSize gem
    #
    def get_image_size
      @source_path = self.path.nil? ? get_source_path : self.get_source_filepath
      @size = "size not recognizes"
      open(@source_path, "rb") do |fh|
        @size = ImageSize.new(fh.read).get_size
      end
      @size
    end

    #
    # Some fake data, if you want
    #
    def seed!
      layout_source  = "/HAML\n.container-fluid\n  .row-fluid\n    .span2\n    .span8\n      %content:test\n    .span2"
      content_source = "/HAML\n.row-fluid\n  .span12\n    %h2.calign\n      TitleText\n    %p\n      ContentText"
      seeds = {
        SourceType::LAYOUT => layout_source,
        SourceType::CONTENT => content_source
      }
      unless seeds[self.type].blank?
        self.data = seeds[self.type]
        save!
        p "Seed content loaded"
      end
    end

  end
end
