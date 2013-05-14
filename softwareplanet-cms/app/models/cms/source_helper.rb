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
        SourceSettings.new.read_source_settings(settings)
      end


      # Before filter method, to pre-process incoming parameters
      def prepare_parameters(params)
        params[:publish] = params[:publish] == 'on' ? 0 : 1
        params[:display] = params[:display] =='on' ? 0 : 1
        params
      end

      # Creates layout, default settings file and css (.scss)
      def create_page(params)
        name = params[:name]
        layout = Source.build(:type => SourceType::LAYOUT, :name => name)
        Source.build(:type => SourceType::CSS, :name => name + '.scss', :target => layout)
        settings_file = Source.build(:type => SourceType::SETTINGS, :name => name, :target => layout)

        settings_builder = SourceSettings.new.elect_params( prepare_parameters(params) )
        settings_builder.write_source_settings(settings_file)
        layout
      end

      def load_gallery(params)
        hash ={}
        current_path = params[:path] ? params[:path] : SOURCE_FOLDERS[SourceType::IMAGE]

        hash['breadcrumbs'] = params[:path] ?  params[:path] : current_path

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

      def create_folder(params)
        path = params[:path]
        filepath = Source.mkdir(path)
        dir = OpenStruct.new
        dir.name = File.basename(filepath)
        dir.path = File.dirname(filepath)
        dir.size = Dir.glob(filepath + '/*').size
        dir
      end

      # Updates layout name and layout settings
      def update_page(id, params)
        layout = Source.get_source_by_id(id)
        new_name = params[:name]
        layout.rename_source(new_name) if new_name != layout.get_source_name

        settings_file = layout.get_source_attach(SourceType::SETTINGS)
        settings_builder = SourceSettings.new.elect_params( prepare_parameters(params) )
        settings_builder.write_source_settings(settings_file)
        layout
      end

    end#ClassMethods
    extend ClassMethods

    def create_default_settings
      Source.build(:type => SourceType::SETTINGS, :name => self.get_source_name, :data => SourceSettings.default_settings.to_s, :target => self)
    end

    def create_default_seo
      Source.build(:type => SourceType::SEO, :name => self.get_source_name, :data => SourceSEO.default_seo, :target => self)
    end

  end
end