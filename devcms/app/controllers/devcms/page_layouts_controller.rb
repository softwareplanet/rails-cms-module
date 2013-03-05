require_dependency "devcms/application_controller"

module Devcms
  class PageLayoutsController < ApplicationController
    before_filter :admin_access

    def show
      @page_layout = PageLayout.find(params[:id])
      @layout_source = PageLayout.build(@page_layout, @application_data).gsub(NEWLINE_SEPARATOR, "\n")
    end

    def backup
      content = ""
      PageLayout.find_each do |layout|
        content += "name: #{layout.name}\n    source: #{layout.source}\n"
      end
      send_data content,  :filename => "layouts_dump.txt"
    end

    def upload
      uploaded_io = params[:dump]
      File.open(Rails.root.join('public', 'uploads', uploaded_io.original_filename), 'w') do |file|
        file.write(uploaded_io.read)
      end
      str = uploaded_io.read
      puts str
    end

  end
end
