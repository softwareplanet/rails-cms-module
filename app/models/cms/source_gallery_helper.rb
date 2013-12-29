# Source Compiler

module Cms
  module SourceGalleryHelper
    module ClassMethods

      def mkdir(path, fname = 'folder')
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

      def rename_dir(params)
        raise('wrong name') unless !/\W/.match(params[:new_name])
        new_filepath = params[:path] + params[:new_name]
        old_filepath = params[:path] + params[:old_name]
        FileUtils.mv(old_filepath, new_filepath) unless new_filepath == old_filepath
        new_filepath
      end

      def delete_dir(path)
        if path.match('public/')
          FileUtils.rm_rf(path)
        end
      end

    end; extend ClassMethods
  end
end