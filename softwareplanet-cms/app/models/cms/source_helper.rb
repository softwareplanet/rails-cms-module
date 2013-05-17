# Methods:

#   get_source_settings_attributes  # <= layout source settings attributes
#   get_source_settings_file        # <= layout source settings file
#   get_source_seo                  # <= layout source seo tags
#   read_seo_values                 # <= hash seo tags

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
        layouts = Source.where(:type => SourceType::LAYOUT)
        if parent_layout
          layouts = layouts.select{|layout| layout.target == parent_layout}
        end
        layout_names = layouts.map(&:get_source_id)
        order_settings.set_data(layout_names.join(','))
        order_settings
      end
      #
      #
      def get_order_settings(list_id, ordered_items_type=nil)
        if list_id.nil?
          order_file_name = 'base_order_type_'+ordered_items_type.to_s
          if (list_order = Source.find_source_by_type_and_name(SourceType::ORDER, order_file_name)).empty?
            list_order = Source.build(:type => SourceType::ORDER, :name => order_file_name)
          end
          all_items_ids = Source.where(:type => ordered_items_type).map(&:get_source_id)
        else
          list_source = Source.get_source_by_id(list_id)
          if (list_order = list_source.get_source_attach(SourceType::ORDER)).nil?
            list_order = Source.build(:type => SourceType::ORDER, :name => list_source.get_source_name, :parent => list_source)
          end
          all_items_ids = Source.where(:type => list_source)
          all_items_ids = all_items_ids.to_a.select{|source| source.get_source_target &&  source.get_source_target.get_source_id == list_source.get_source_id}.map(&:get_source_id)
        end
        list_order = list_order.first if list_order.is_a?(Array)
        [list_order, all_items_ids]
      end
      #
      #
      def get_order(list_id, ordered_items_type=nil)
        list_order, all_items_ids = get_order_settings(list_id, ordered_items_type)
        order_data = list_order.get_data.split(',')
        # cleanup order_data
        order_data.each_with_index do |order_item_id, index|
          all_items_ids.delete(order_item_id)
          order_source = Source.get_source_by_id(order_item_id)
          if order_source.nil?
            order_data[index] = nil
          end
        end
        if order_data.include?(nil) || all_items_ids.any?
          order_data = order_data + all_items_ids
          order_string = (order_data).compact.join(',')
          list_order.set_data(order_string)
        end
        order_data.compact
      end
      # Reorder list of layouts at some structure level.
      # If parent is empty, reorder on top level
      def set_order(list_id, ordered_items_array,  ordered_items_type=nil)
        list_order, all_items_ids = get_order_settings(list_id, ordered_items_type)
        order_data = (ordered_items_array + all_items_ids).uniq
        list_order.set_data(order_data.join(','))
        order_data
      end

      # Read source settings attributes from settings file
      # If settings file not exists, it will be created with default settings
      def get_source_settings_attributes(source_id)
        SourceSettings.new.read_source_settings( get_source_settings_file(source_id) )
      end

      # Read source settings file, type Source
      # If settings file not exists, it will be created with default settings
      def get_source_settings_file(source_id)
        source = Source.get_source_by_id(source_id)
        settings_file = source.get_source_attach(SourceType::SETTINGS)
        settings_file = source.create_default_settings if settings_file.nil?
        settings_file
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

        hash['breadcrumbs'] = current_path

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
    end; extend ClassMethods

    def create_default_settings
      Source.build(:type => SourceType::SETTINGS, :name => self.get_source_name, :data => SourceSettings.default_settings.to_s, :target => self)
    end
  end
end