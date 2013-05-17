# Search Accelerator
# Methods:
#   find_source_by_name_and_type  # <= quick search by name and type

module Cms
  module SourceSearchAccelerator
    module ClassMethods

      def find_source_by_name_and_type(source_name, source_type)
        puts "accelerated method used.."
        files = Array.new
        dir = AdapterStable.get_source_folder(source_type)
        Dir.glob(dir+"**/*"+source_name).each do |f|
          s = build_source(f, source_type)
          files.push(s) unless s.nil?
        end
        files
      end

    end; extend ClassMethods
  end
end