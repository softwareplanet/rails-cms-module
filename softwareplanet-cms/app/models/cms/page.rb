module Cms
  class Page

    # Composes the layout with included contents, variables, etc..
    # Wraps each content with unique id
    # Returns the array in form [  html, wrapper_id, [stylesheets_filenames] ]
    def self.compose(layout_name, var_hash)
      is_admin = var_hash[:admin?] == true

      #slow:
      #layout = Source.find_by_type_and_name(SourceType::LAYOUT,  layout_name).first
      #quick:
      layout = Source.find_source_by_name_and_type(layout_name, SourceType::LAYOUT).first

      if layout.nil?
        raise ArgumentError, "Attempt to generate layout<b> #{layout_name}"
      end

      str = layout.get_data

      page_styles = []

      #slow:
      #slow_style_path = CUSTOM_SCSS_FOLDER + layout.get_attach.get_filename
      #quick:
      page_styles << "custom/" + layout.get_source_attach(SourceType::CSS).get_source_filename

      plain_src = str.gsub(/[" "]*%content:([\w_\-]+)/) { |r|
        offset_length = r.gsub(/[\s\/]*/).first.length
        next_line_offset_length = offset_length + 2
        offset_whitespaces = " " * offset_length
        next_line_offset_whitespaces = " " * next_line_offset_length

        content_name = /:([\w_\-]+)/.match(r)[1]

        #slow:
        #replacement = Source.find_by_name_and_type(content_name, SourceType::CONTENT).first
        #quick:
        replacement = Source.quick_content_search(content_name, SourceType::CONTENT)
        raise ArgumentError, "Content with name #{content_name} is not found!" if replacement.blank?


        # slow
        #page_styles << (CUSTOM_SCSS_FOLDER + replacement.get_attach.get_filename) unless replacement.get_attach.blank?
        # quick

        # TODO!! DISABLED BECAUSE ALL STYLES INCLUDED IN SINGLE (LAYOUT) CSS!!!!!! Uncomment!
        #custom_style = CUSTOM_SCSS_FOLDER + "2" + Cms::TARGET_DIVIDER + replacement.name + ".scss"
        #page_styles << custom_style

        content_source = replacement.build(var_hash, layout)
        prepended = content_source.prepend(next_line_offset_whitespaces)
        gsub_value = ("\n" + " "*next_line_offset_length)
        header_named_editable_content = "%div#{ ".editable-long-text" if replacement.editable && is_admin }{'data-content_name' => '#{replacement.name}', :id => '#{replacement.get_id.to_s}'}".prepend(offset_whitespaces) + NEWLINE


        header_named_editable_content + prepended.gsub("\n", gsub_value)
      }
      puts page_styles.inspect

      seo_string = layout.get_source_attach(SourceType::SEO).get_data

      # parse data. locales separated by '%ru' or '%en' titles:

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

      [plain_src, layout.get_id, page_styles, seo_tags]
    end
  end
end
