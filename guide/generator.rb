# Available formatting tabs: |TIP|IMPORTANT|CAUTION|WARNING|NOTE|INFO|TODO|.|:|

# Version number: [major].[minor].[release].[build]
RAILS_CMS_VERSION = 'v'+File.read(File.expand_path('../../CMS_VERSION', __FILE__)).strip

MARKDOWN_DIR = './md/'
RESOURCES_DIR = './resources/'
LAYOUT_NAME = 'layout'
OUTPUT_PATH = './compiled/'
GUIDES = /\.(?:erb|md)\z/

require_relative 'render_engine'
require_relative 'helpers'
require 'action_view'
require 'fileutils'

FileUtils.rm_rf(OUTPUT_PATH)
FileUtils.mkpath(OUTPUT_PATH)
FileUtils.cp_r(Dir.glob("#{RESOURCES_DIR}*"), OUTPUT_PATH)

guides =  Dir.glob("#{MARKDOWN_DIR}*").grep(GUIDES)

guides.each do |markdown_guide|
  next if File.directory?(markdown_guide)
  puts "Process file #{markdown_guide}"

  input_file_name = markdown_guide.split('/').last
  output_file_name = input_file_name.split('.').first + '.html'
  output_file_path = OUTPUT_PATH + output_file_name

  File.open(output_file_path, 'w') do |guide|
    view = ActionView::Base.new(MARKDOWN_DIR)
    view.extend(Helpers)

    #layout = MARKDOWN_DIR+LAYOUT_NAME
    layout = LAYOUT_NAME
    if input_file_name =~ /\.(\w+)\.erb$/
      # Generate the special pages like the home.
      # Passing a template handler in the template name is deprecated. So pass the file name without the extension.
      result = view.render(:layout => layout, :formats => [$1], :file => $`)
    else
      body = File.read(markdown_guide)
      result = Markdown.new(view, layout).render(body)
    end
    guide.write(result)
    puts "Rendered to #{output_file_path}"
  end
end
puts 'done'


