require "image_size"

module Cms
  require 'ostruct'
  require_relative 'source_settings'
  require_relative 'source_seo'
  require_relative 'source_helper'
  require_relative 'adapter_stable'
  require_relative 'adapter_stable_aliases'

  # deprecated:
  #require_relative 'adapter'

  class Source < OpenStruct

    # deprecated:
    #include Adapter
    #extend Adapter::ClassMethods

    include AdapterStable
    extend AdapterStable::ClassMethods
    include AdapterStableAliases
    extend AdapterStableAliases::ClassMethods
    include SourceHelper
    extend SourceHelper::ClassMethods

    def self.quick_get_layout_name_by_id(layout_id)
      layout_id.gsub(/pre(1|8)-id-/, '')
    end

    def self.quick_build_seo_with_path(layout_id)
      page_name = layout_id.gsub('pre1-id-', '')
      #seo_id = layout_id.gsub('pre1-id-', '1-tar-')
      seo = Source.quick_attach(SourceType::LAYOUT, page_name, SourceType::SEO)
      path = seo.get_source_folder + seo.name
      [seo, path]
    end

    def self.quick_search(type,  name)
      ext =  SOURCE_TYPE_EXTENSIONS[type.to_i]
      Source.new({ :type => type, :name => name, :extension => ext, :data => nil })
    end

    def self.quick_attach(type, name, attach_type)
        ext =  SOURCE_TYPE_EXTENSIONS[attach_type.to_i]
      attach_name = type.to_s + Cms::TARGET_DIVIDER + name
      Source.new({ :type => attach_type, :name => attach_name, :extension => ext, :data => nil })
    end

    def self.quick_attach_short_path(type, name, attach_type)
      attach_name = type.to_s + Cms::TARGET_DIVIDER + name
      if attach_type == SourceType::CSS
        return CUSTOM_SCSS_FOLDER + attach_name
      end
      raise "oops for other types"
    end

    def self.quick_content_search(content_name, content_type)
      ext = SOURCE_TYPE_EXTENSIONS[content_type.to_i]
      Source.new({ :type => content_type, :name => content_name, :extension => ext, :data => nil })
    end

    def get_image_path
      get_source_path["public".size..-1]
    end

    def get_image_size
      if self.path.nil?
        @source_path = get_source_path
      else
        @source_path = self.path + self.name + self.get_extension
      end
      @size = "not detected"
      open(@source_path, "rb") do |fh|
        @size = ImageSize.new(fh.read).get_size
      end
      @size
    end

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

    def create_style_file
      scss = ('#' + get_id + '{' + NEWLINE_SEPARATOR + data + NEWLINE_SEPARATOR + '}').gsub(NEWLINE_SEPARATOR, "\n")
      self.data = scss
      self.save!
    end

    def get_text(text_id, layout, var_hash, source_id, lang_id)
      tag_id = "#{source_id}-#{lang_id}-#{text_id}"

      localized = SiteLocal.find_by_tag_id tag_id
      if localized.nil?
        localized = SiteLocal.create(:tag_id => tag_id, :text => "#{lang_name}=(#{text_id})")
      end
      localized.text.gsub!("\n", '')
      prepended_aloha_tags = ""
      is_admin = var_hash[:admin?] == true
      prepended_aloha_tags = ".aloha-editable.editable-long-text{'data-content_name' => '#{tag_id}'} " if is_admin
      # Trick with empty text:
      if localized.text.blank?
        localized.update_attribute(:text, "#{lang_name}=(#{text_id})")
      end

      prepended_aloha_tags + localized.text
    end

    def get_image(image_id, image_size, layout, var_hash, source_id, lang_id)
      is_admin = var_hash[:admin?] || false

      image_class = " class='changeable-image' " if is_admin
      image_styles_attr = " style='font-size: 10px' "
      if image_size
        image_width_attr = "width='#{image_size.split('x')[0]}' "
        image_height_attr = "height='#{image_size.split('x')[1]}' "
        image_styles_attr = " style='font-size: 10px; height:#{image_size.split('x')[1]}px!important' " if is_admin
      else
        image_width_attr = "width='100px' "
        image_height_attr = "height='100px' "
      end
      image_size_specified = image_size ? true : false


      tag_id = "#{source_id}-#{lang_id}-#{image_id}"
      localized = SiteLocal.find_by_tag_id tag_id
      if localized.nil?
        localized = SiteLocal.create(:tag_id => tag_id, :text => "#{image_id}#{image_size}")
        image_src = "#"
      else
        image_src = localized.text
        unless image_size
          image_width_attr = image_height_attr = ""
        end
      end

      #source = Source.where(:name => image_id, :type => SourceType::IMAGE).first
      #if source
      #  width, height = source.get_image_size
      #end

      #if image_size && source
      #  if image_size.split('x')[0] != width || image_size.split('x')[1] != height
      #    image_src = "#"
      #  end
      #end
     resulted_value = "<img id='#{tag_id}' src='#{image_src}' #{image_class.to_s} #{image_width_attr.to_s} #{image_height_attr.to_s} alt='#{image_id}#{image_size}' #{image_styles_attr} data-hardsize='#{image_size_specified}'/>"
    end

    def build(var_hash, layout)
      is_admin = var_hash[:admin?] == true
      src = self.data

      lang_name = var_hash[:locale]
      lang_id = SiteLanguage.find_by_url(lang_name).id

      # Build variables
      plain_src = src.gsub(/%var:([\w\-\"_\']+)/) { |r|
        var_name = /:([\w_\-\"\']+)/.match(r)[1]

        @resulted_value = ""
        if var_name.match(/^text/).to_s.length > 0
          text_id = var_name["text".length..-1].to_s
          @resulted_value = get_text(text_id, layout, var_hash, self.get_id, lang_id)
        elsif var_name.match(/^image/).to_s.length > 0
          image_size_attr = /image(\w+)/.match(r)
          offset = image_size_attr.nil? ? "image".length+1 : image_size_attr[0].length+1
          image_size = image_size_attr ? image_size_attr[1] : nil
          image_id = var_name[offset..-2].to_s
          @resulted_value = get_image(image_id, image_size, layout, var_hash, self.get_id, lang_id)
        elsif false #...var_name.match(/^%content:/).to_s.length > 0

        else
          @resulted_value = var_hash[var_name.to_sym]
        end
        @resulted_value
      }

      # With image size:
      plain_src = plain_src.gsub(/%image[\w]*:[\w\-\"_\']+/) { |r|
        resulted_value = ""
        image_size_attr = /%image(\w+)/.match(r)
        image_size = image_size_attr.nil? ? nil : image_size_attr[1].split("x")

        image_name = /:([\w_\-\"\']+)/.match(r)[1]

        image_source = Source.where(:type => SourceType::IMAGE, :name => image_name).first

        image_size_specified = image_size ? true : false

        image_styles_attr = " style='font-size: 10px' "
        unless image_source.blank?
          if image_size
            image_width_attr = "width='#{image_size[0]}' "
            image_height_attr = "height='#{image_size[1]}' "
            image_styles_attr = " style='font-size: 10px; height:#{image_size[1]}px!important' " if is_admin
          end
        else
          # specify height and width for alternative text visibility:
          image_width_attr = " width='100px' "
          image_height_attr = " height='30px' "
        end
        image_class = " class='changeable-image' " if is_admin
        image_id = " id='#{image_source.get_id}' " if image_source && is_admin


        width, height = image_source.get_image_size
        if image_size
          if image_size[0] != width.to_s || image_size[1] != height.to_s
            image_source = nil
          end
        end


        resulted_value = "<img #{image_id} src='#{image_source ? image_source.get_image_path : '#'}' #{image_class.to_s} #{image_width_attr.to_s} #{image_height_attr.to_s} alt='#{image_source ? image_source.name : image_name}#{image_size_attr[1] if image_size_attr}' #{image_styles_attr} data-hardsize='#{image_size_specified}'/>"
        resulted_value
      }

      return plain_src
    end

    def self.mkdir(path, fname = 'folder')
      #path = 'public/img/'

      raise('wrong name') unless !/\W/.match(fname)

      if !File.directory?(path+fname)
        Dir.mkdir(path+fname)
        return path+fname
      else
        i = 2
        while true
          if !File.directory?(path+fname + i.to_s)
            Dir.mkdir(path+fname + i.to_s)
            return path+fname + i.to_s
          end
          i+=1
        end
      end
    end

    def self.rename_dir(old_path, fname)
      raise('wrong name') unless !/\W/.match(fname)
      new_path = Pathname.new(old_path).dirname.to_s + '/' + fname
      FileUtils.mv(old_path, new_path) unless new_path == old_path
      new_path
    end

    def self.delete_dir(path)
      if path.match('public/')
        FileUtils.rm_rf(path)
      end
    end
  end
end
