# Source Compiler

module Cms
  module SourceCompiler
    module ClassMethods
    end; extend ClassMethods

    def get_text(text_id, layout, var_hash, source_id, lang_id)
      tag_id = "#{source_id}-#{lang_id}-#{text_id}"

      localized = SiteLocal.find_by_tag_id tag_id
      if localized.nil?
        localized = SiteLocal.create(:tag_id => tag_id, :text => "#{lang_name}=(#{text_id})")
      end
      localized.text.gsub!("\n", '')
      prepended_aloha_tags = ""
      is_admin = var_hash[:admin_view?] == true
      prepended_aloha_tags = ".aloha-editable.editable-long-text{'data-content_name' => '#{tag_id}'} " if is_admin
      # Trick with empty text:
      if localized.text.blank?
        localized.update_attribute(:text, "#{lang_name}=(#{text_id})")
      end

      prepended_aloha_tags + localized.text
    end

    def get_image(image_id, image_class, image_size, layout, var_hash, source_id, lang_id)
      is_admin = var_hash[:admin_view?] || false

      if is_admin
        image_class = image_class ? "#{image_class} changeable-image" : "changeable-image"
      end

      class_str = image_class ? "class='#{image_class}'" : ""

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
        #img = Source.find_source_by_name_and_type(localized.text+".*", SourceType::IMAGE).first
        img = Source.find_source_by_name_and_type(localized.text.split('/').last, SourceType::IMAGE).first
        image_src = img ? img.get_image_path : "#!"
        unless image_size
          image_width_attr = image_height_attr = ""
        end
      end
      resulted_value = "<img id='#{tag_id}' #{class_str} src='#{image_src}' #{image_width_attr.to_s} #{image_height_attr.to_s} alt='#{image_id}#{image_size}' #{image_styles_attr} data-hardsize='#{image_size_specified}'/>"
    end

    #
    #
    #
    def build_variables(src, lang_id, var_hash)
      is_admin = var_hash[:admin_view?] == true
      src.gsub(/%var:([\w\-\"_\'\.]+)/) { |r|
        var_name = /:([\w_\-\"\'\.]+)/.match(r)[1]

        @resulted_value = ""
        if var_name.match(/^text/).to_s.length > 0
          text_id = var_name["text".length..-1].to_s.gsub("\'", "\"")
          @resulted_value = get_text(text_id, layout, var_hash, self.get_id, lang_id)
        elsif var_name.match(/^image/).to_s.length > 0
          image_size_attr = /:image(\w+)/.match(r)  #%var:image.span3\"cubex_logo_header\"
          image_class_attr = /:image\w*\.((\w|\-)+)(\"|')/.match(r)

          offset = image_size_attr.nil? ? "image".length+1 : image_size_attr[0].length+1
          offset += image_class_attr.nil? ? 0 : image_class_attr[1].length+1

          image_size = image_size_attr ? image_size_attr[1] : nil
          image_class = image_class_attr ? image_class_attr[1] : nil


          image_id = var_name[offset..-2].to_s
          @resulted_value = get_image(image_id, image_class, image_size, layout, var_hash, self.get_id, lang_id)
        elsif false #...var_name.match(/^%content:/).to_s.length > 0

        else
          @resulted_value = var_hash[var_name.to_sym]
        end
        @resulted_value
      }
    end

    #
    # %var:image100x100
    # lang_id is not used!
    #
    def build_image_size_variables(src, lang_id, var_hash)
      is_admin = var_hash[:admin_view?] == true

      src.gsub(/%image[\w]*:[\w\-\"_\']+/) { |r|
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
    end

    def build(var_hash, layout)
      is_admin = var_hash[:admin_view?] == true
      self.load!
      src = self.data
      lang_name = var_hash[:locale]
      lang_id = SiteLanguage.find_by_url(lang_name).id

      # Build variables
      plain_src = build_variables(src, lang_id, var_hash)

      # With image size:
      plain_src = build_image_size_variables(plain_src, lang_id, var_hash)

      return plain_src
    end

  end
end