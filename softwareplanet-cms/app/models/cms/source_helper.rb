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
      #
      #
      def build_default_order_settings(parent_layout=nil)
        order_settings = Source.build(:name => 'order', :type => SourceType::LAYOUTS_ORDER, :parent => layout)
        layouts = Source.where(:type => SourceType::LAYOUTS_ORDER)
        top_level_layouts = layouts.select{|layout| layout.target == nil}
      end
      #
      #
      def get_order_settings(parent_source, source_type)
        if parent_source == nil
          order_settings = Source.find_by_name_and_type('order'+source_type.to_s, SourceType::LAYOUTS_ORDER)
          if order_settings.nil?
            build_default_order_settings
          end

        end
      end
      # Reorder list of layouts at some structure level.
      # If parent is empty, reorder on top level
      def reorder(items, list_id)
        #order_settings = get_order_settings(list_id, SourceType::LAYOUT)
        #TODO: reorder
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

      def create_page(params)
        hash ={}
        name = params[:name]
        parsed_settings = SourceSettings.new
        parsed_settings.publish = params[:publish] == 'on' ? 0 : 1
        parsed_settings.display = params[:display] =='on' ? 0 : 1
        parsed_seo_tags = SourceSEO.new
        parsed_seo_tags.title = params[:title] ? params[:title] : ''
        parsed_seo_tags.keywords = params[:keywords] ? params[:keywords] : ''
        parsed_seo_tags.description = params[:description] ? params[:description] : ''
        layout = Source.build(:type => SourceType::LAYOUT, :name => name)
        hash['layout'] = layout
        hash['css'] =  Source.build(:type => SourceType::CSS, :target => layout, :name => name + '.scss')
        hash['seo'] = Source.build(:type => SourceType::SEO, :target => layout, :name => name, :data => parsed_seo_tags.get_data)
        hash['settings'] = Source.build(:type => SourceType::SETTINGS, :target => layout, :name => name, :data => parsed_settings.get_data)
        hash
      end

      def load_gallery(params)
        hash ={}
        current_path = params[:path] ? params[:path] : SOURCE_FOLDERS[SourceType::IMAGE]

        hash['breadcrumbs'] = params[:path] ?  params[:path] : '/'

        hash['folders'] = []
        Dir.glob(current_path + '*').each do |file|
          if File.directory?(file)
            dir = OpenStruct.new
            dir.name = File.basename(file)
            dir.path = current_path
            dir.size = Dir.glob(file + '/*').size
            hash['folders'].push(dir)
          end
        end

        hash['images'] = []
        sources = Source.find_source_by_path(current_path)
        sources.each do |source|
          filepath = source.get_source_filepath
          hash['images'].push(source) unless File.directory?(filepath)
        end
        hash
      end

      def create_folder

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