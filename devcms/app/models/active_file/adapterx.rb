require 'active_support/core_ext/object/blank'

module ActiveFile
  module Adapterx
    require 'fileutils'

    @@base_folder = 'data_source'

    attr_accessor :name

    def initialize(name_arg)
      name = name_arg
    end

    def save

    end


    # STATIC METHODS MODULE
    module ClassMethods

    end







  end
end




=begin
module ActiveFile
  # Data Source Storage Adapter
  module Adapterx
    require 'fileutils'
    RAISE_TRUE = true
    RAISE_FALSE = false
    BASE_FOLDER = 'data_source'

    attr_accessor :name

    def initialize name_arg
      self.name = name_arg
    end

    # touch file to read!
    def load!
      self.data
      self
    end

    def data= data_arg
      @self_data = data_arg
    end

    def data
      if @self_data == nil
        @self_data = ::File.read(self.get_source_path)
      end
      @self_data || ""
    end

    # Main rule to link attaches (css) with their targets (layouts, contents). Special filename format used for this purpose;
    def attach_my_name!
      # Is we an attached instance?
      unless self.target.nil?
        #@ext = CSS_EXT  if self.type == SourceType::CSS
        self.name = target.type.to_s + TARGET_DIVIDER + target.name #+ @ext.to_s
      end
    end

    # Get source folder. Create, if not exists.
    def get_source_folder
      Adapter.get_source_folder(type)
    end
    def get_name
      attach_my_name!
      return name
    end
    # Get source filename
    def get_filename
      #get_name + get_extension
      get_name
    end
    # Alias for get_source_path
    def get_filepath
      get_source_path
    end
    # Get source path. For targeted objects, target name + '--' + target type appends
    def get_source_path
      raise ArgumentError, 'Name can not be blank!' if name.blank? && target.nil?
      raise ArgumentError, 'Target name can not be blank!' if target && target.name.blank?
      get_source_folder + get_filename
    end
    def get_extension
      return ".scss" if type == SourceType::CSS
      return extension.blank? ? "" : "."+extension

      type_ext = SOURCE_TYPE_EXTENSIONS[type.to_i] || ""
      return "" if type_ext == "*"
      if type_ext == "*"
        unless new_record?
        # Custom extension, from filename
          Dir.glob(dir+"*").each do |f|
            name_with_extension = f.split('/').last
            name, ext = name_with_extension.split('.')
            if name == get_name
              type_ext = ext
              break
            end
          end
        else
          _name, _ext = name.split(".")
          unless _name.empty? && _ext.empty?
            type_ext = _ext
          end
        end
      end
      type_ext = "." + type_ext unless type_ext.empty?
      type_ext
    end
    # Get unique id of the source
    def get_id
      ID_PREFIX + type.to_s + ID_DIVIDER + get_name
    end
    # Rename the source file, return boolean operation result
    def rename(new_file_name)
      raise "Source is new record, call the save! method before rename." if new_record?
      # rename attached file, if present ()
      attach = get_attach
      # later..
      old_file_path = get_source_path
      new_file_path = get_source_folder + new_file_name + get_extension
      b_result = !!::File.rename(old_file_path, new_file_path)
      raise "Unable to rename source" unless b_result
      self.name = new_file_name
      if attach
        # to rename attach, create new copy of attached object with new target name, and delete old
        attach_source = attach.clone
        attach_source.target = self
        b_result = attach_source.save! && attach.delete!
        raise 'Attached file rename failed' unless b_result
      end
      b_result
    end
    def new_record?
      !::File.exists?(get_source_path)
    end
  private
    def save_method(raise_exception_on_error)
      ::File.open(get_source_path, "w") do
        |file| file.write(data.force_encoding('utf-8'))
      end
      true
    rescue => e
      return raise_exception_on_error == RAISE_TRUE ? raise(e) : false
    end
    def delete_method(raise_exception_on_error)
      delete_file_name = get_source_path
      ::File.delete(delete_file_name)
      return true
    rescue => e
      return raise_exception_on_error == RAISE_TRUE ? raise(e) : false
    end
  public
    # Save the source, return boolean operation result
    def save
      save_method(RAISE_FALSE)
    end
    def save!
      save_method(RAISE_TRUE)
    end
    # Delete the source: if successful returns true, else return false
    def delete
      delete_method(RAISE_FALSE)
    end
    # Delete the source: if successful returns true, else raise an error
    def delete!
      raise StandardError, "Unable to delete file if object hasn't been saved yet" if new_record?
      delete_method(RAISE_TRUE)
    end
    def get_target_type
      name.split(TARGET_DIVIDER)[0]
    end
    def get_target_name
      name.split(TARGET_DIVIDER)[1]
    end
    # Get target object
    def get_target
      return nil unless name.include?(TARGET_DIVIDER)
      #target_type, target_name = name[0..-2].split(TARGET_DIVIDER)
      target_type = get_target_type
      target_name = get_target_name

      target_type_extension = SOURCE_TYPE_EXTENSIONS[target_type.to_i]
      unless target_type_extension.empty?
        target_type_extension = "." + target_type_extension
      end

      target =  Adapter.get_source_folder(target_type) + target_name + target_type_extension
      return nil unless ::File.exists?(target)
      return Source.new({ :type => target_type.to_i, :name => target_name, :data => nil })
    end
    # Get attached object
    def get_attach attach_type=SourceType::CSS
      Adapter.where(:type => attach_type, :name => get_attached_name).first
    end
    def get_attached_name
      type.to_s + TARGET_DIVIDER + name
    end
    #def get_attached_filename
    #  attached_file_extension = SOURCE_TYPE_EXTENSIONS[attach_type.to_i]
    #  attached_file_extension = "." + attached_file_extension unless attached_file_extension.empty?
    #  type.to_s + TARGET_DIVIDER + name + attached_file_extension
    #end
    def get_attach_or_create attach_type=SourceType::CSS
      attach = get_attach(attach_type)
      if attach.nil?
        attach = Source.new(:type => attach_type, :extension => SOURCE_TYPE_EXTENSIONS[attach_type])
        attach.target = self
        attach.save!
      end
      attach
    end
    #
    # STATIC METHODS MODULE
    module ClassMethods
      # Creates a new source instance and saves it to disk. Returns the newly created source. If a failure has occurred or source already exists -
      # an exception will be raised.
      def create(attributes={})
        raise ArgumentError, "expected an attributes Hash, got #{attributes.inspect}" unless attributes.is_a?(Hash)
        source_instance = Source.new(attributes)
        raise 'Source file with such name already exists!' if ::File.exists?(source_instance.get_source_path)
        source_instance.save!
        return source_instance
      end
      # Get source folder for any source type. Create, if not exists.
      def get_source_folder(type)
        #source_folder = Rails.env == 'test' ? TEST_SOURCE_FOLDERS[type.to_i || SourceType::UNDEFINED] : SOURCE_FOLDERS[type.to_i || SourceType::UNDEFINED]
        source_folder = BASE_FOLDER + "/" + type.to_s + "/"
        FileUtils.mkpath(source_folder) unless ::File.exists?(source_folder)
        return source_folder
      end
      # Get names array of all sources with specified type
      def all_by_type(source_type)
        files = Array.new
        dir = Adapter.get_source_folder(source_type)
        source_extension = SOURCE_TYPE_EXTENSIONS[source_type.to_i]

        Dir.glob(dir+"*").each do |f|
          name_with_extension = f.split('/').last
          extension = name_with_extension.split('.').size > 1 ? name_with_extension.split('.').last : ""
          name_without_extension = nil

          name_without_extension = name_with_extension

          if source_extension.blank?
            name_without_extension = name_with_extension
          else
            name_without_extension = source_extension == "*" ? name_with_extension.split('.').first : name_with_extension[0..-source_extension.length-2]
          end

          s = Source.new({ :type => source_type, :name => name_without_extension, :extension => extension, :data => nil })
          target_object = s.get_target
          s.target = target_object unless target_object.nil?
          files.push(s)
        end
        return files
      end
      def all
        (Rails.env == 'test' ? TEST_SOURCE_FOLDERS : SOURCE_FOLDERS).map {|key_type, val| Adapter.all_by_type(key_type) }.reject { |ar| ar.empty? }.flatten
      end
      # Find the source
      def where(attributes)
        raise ArgumentError, "expected an attributes Hash, got #{attributes.inspect}" unless attributes.is_a?(Hash)
        Adapter.all.select do |source|
          match = true
          attributes.each{|key, val|
            match = false if source.send(key) != val
          }
          match
        end
      end
      def find_by_id(id)
        id = id[ID_PREFIX.size .. -1]
        type, name = id.include?(TARGET_DIVIDER) ? (id).split(ID_DIVIDER) : id.split(ID_DIVIDER)
        Adapter.find_by_name_and_type(name, type.to_i).first
      end
      # Complex finders:
      def method_missing(m, *args, &block)
        if m.to_s.index("find_by_") == 0
          attributes = m["find_by_".size..-1].split("_and_")
          raise "Attributes count expected: #{attributes.size}, got: #{args.size}" unless attributes.size == args.size
          match_hash = {}
          attributes.each_with_index {|attr, index| match_hash[attr.to_sym] = args[index]}
          return Adapter.where(match_hash)
        else
          puts "There's no method called #{m} here -- please try again with args #{args}"
        end
      end
    end
    extend ClassMethods
  end
end
=end