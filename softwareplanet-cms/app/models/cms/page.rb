module Cms
  class Page

    def self.get_compiled_source(layout_name, lang_path)
      compiled_file_folder = Source.get_source_folder(SourceType::COMPILED) + lang_path + "/"
      compiled_file_path = compiled_file_folder + layout_name
      compiled_layout = File.read(compiled_file_path) if File.exists?(compiled_file_path)
      compiled_layout
    end

    def self.create_compiled_source(compiled_layout, layout_name, lang_path)
      compiled_file_folder = Source.get_source_folder(SourceType::COMPILED) + lang_path + "/"
      compiled_file_path = compiled_file_folder + layout_name
      FileUtils.mkpath(compiled_file_folder) unless File.exists?(compiled_file_folder)
      File.open(compiled_file_path, "w") do |file|
        file.write(compiled_layout.force_encoding('utf-8'))
      end
    end

    def self.get_sorted_gallery_images
      formats = %w(.gif .jpeg .jpg .bmp .png .tiff)
      @images = Source.find_source_by_type(SourceType::IMAGE).select{|i| i.filename.downcase.end_with?(*formats)}
      @images.sort! { |a,b|
        # A generic algorithm for sorting strings that contain non-padded sequence numbers at arbitrary positions.
        # http://stackoverflow.com/questions/12943538
        padding = 4
        a,b = [a,b].map{|s| s.filename.gsub(/\d+/){|m| "0"*(padding - m.size) + m } }
        a<=>b
      }
    end

    # Composes the layout with included contents, variables, etc..
    # Wraps each content with unique id
    # Returns the array in form [  html, wrapper_id, [stylesheets_filenames] ]
    def self.compose(layout_name, var_hash)

      #css_path = ''
      css_path='custom/'

      is_admin = var_hash[:admin?] == true
      layout = Source.find_source_by_name_and_type(layout_name, SourceType::LAYOUT).first
      if layout.nil?
        raise ArgumentError, "Attempt to generate layout<b> #{layout_name}"
      end

      head_content = layout.get_source_attach_or_create(SourceType::HEAD).get_data

      str = layout.get_data

      page_styles = []

      page_styles << css_path + layout.get_source_attach(SourceType::CSS).get_source_filename

      plain_src = str.gsub(/[" "]*%content:([\w_\-]+)/) { |r|
        offset_length = r.gsub(/[\s\/]*/).first.length
        next_line_offset_length = offset_length + 2
        offset_whitespaces = " " * offset_length
        next_line_offset_whitespaces = " " * next_line_offset_length
        content_name = /:([\w_\-]+)/.match(r)[1]
        replacement = Source.quick_content_search(content_name, SourceType::CONTENT)
        raise ArgumentError, "Content with name #{content_name} is not found!" if replacement.blank?

        custom_style = css_path +  "2" + Cms::TARGET_DIVIDER + replacement.name + Cms::TARGET_DIVIDER + replacement.name + ".scss"
        page_styles << custom_style

        content_source = replacement.build(var_hash, layout)
        prepended = content_source.prepend(next_line_offset_whitespaces)
        gsub_value = ("\n" + " "*next_line_offset_length)
        header_named_editable_content = "%div#{ ".editable-long-text" if replacement.editable && is_admin }{'data-content_name' => '#{replacement.name}', :id => '#{replacement.get_id.to_s}'}".prepend(offset_whitespaces) + NEWLINE

        header_named_editable_content + prepended.gsub("\n", gsub_value)
      }

      #
      # AutoMenu
      #
      plain_src = inject_menu(plain_src)

      layout_settings = Source.get_source_settings_attributes(layout.get_source_id)
      seo_string =
          "<title>#{layout_settings.title}</title>\n" +
          "<meta name=\"keywords\" content=\"#{layout_settings.keywords}\"/>\n" +
          "<meta name=\"description\" content=\"#{layout_settings.description}\"/>\n"
      seo_tags = seo_string

      # parse data. locales separated by '%ru' or '%en' titles:
      # temporary, feature disabled:
      @INTERNATIONAL_SEO_ENABLE = false

      if @INTERNATIONAL_SEO_ENABLE

        locale = var_hash[:locale]
        ru_index = seo_string.index("%ru")
        en_index = seo_string.index("%en")

        seo_tags = ""

        if ru_index != nil && en_index != nil
          ru_string = (ru_index > en_index) ? seo_string[ru_index+3 .. -1] : seo_string[ru_index+3 .. en_index-1]
          en_string = (en_index > ru_index) ? seo_string[en_index+3 .. -1] : seo_string[en_index+3 .. ru_index-1]
          seo_tags = locale == "ru" ? ru_string : en_string
        elsif ru_index == nil && en_index == nil
          seo_tags = seo_string
        else
          seo_tags = seo_string.gsub('%ru', '').gsub('%en', '')
        end
      end


      [plain_src, layout.get_id, page_styles, seo_tags, head_content]
    end
    #
    # AutoMenu
    #
    def self.inject_menu(plain_src)
      plain_src = plain_src.gsub(/[" "]*%menu/) { |r|
        offset_length = r.gsub(/[\s\/]*/).first.length
        next_line_offset_length = offset_length + 2 - 2
        offset_whitespaces = " " * offset_length
        next_line_offset_whitespaces = " " * next_line_offset_length


        menu_ids = Source.get_order(nil, SourceType::LAYOUT)
        menu_links = menu_ids.collect{|id|
          source = Source.get_source_by_id(id)
          settings = Source.get_source_settings_attributes(id)
          next if settings.no_publish == 1 || settings.no_show == 1
          link_title = settings.menu_title.blank? ? settings.title : settings.menu_title
          "  %li\n    %a{:href=>'"+source.get_source_name+"'}\n      " + link_title + "\n"
        }

        content_source = "%ul.nav.nav-layout\n" + menu_links.join

        prepended = content_source.prepend(next_line_offset_whitespaces)
        gsub_value = ("\n" + " "*next_line_offset_length)
        prepended.gsub("\n", gsub_value)
      }
    end
  end
end
