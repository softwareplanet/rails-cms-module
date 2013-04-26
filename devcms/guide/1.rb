require 'redcarpet'
require_relative 'markdown'

require 'set'
require 'fileutils'

require 'active_support/core_ext/string/output_safety'
require 'active_support/core_ext/object/blank'
require 'action_controller'
require 'action_view'

source_dir = './'
layout = 'layout'

guide = 'RailsCms.md'

output_path = "output.html"

File.open(output_path, 'w') do |f|
  view = ActionView::Base.new(source_dir)  
  body = File.read(File.join(source_dir, guide))
  result = RailsGuides::Markdown.new(view, layout).render(body)
  f.write(result)
end
