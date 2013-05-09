# Stable version of Adapter
#
# Methods:

#   Source.build(name:'1.txt')   # Create ()
#
#
#   detach                        # <= detach source from parent
#   attach_to( source )           # <= attach source to parent

#   flash!                # save
#   drop!                 # delete source, and unlock all attaches
#   eliminate!            # delete source with all attaches, and attaches of attaches ....

#   get_source_name            # css1.css
#   get_source_filename        # 1-tar-main-tar-css1.css
#   get_source_filepath        # /data_source/css/1-tar-main-tar-css1.css

#   get_source_id
#   get_source_by_id

#   get_source_target         # <= [Array]
#   get_source_target           # <= Target Source

#   Source.find_source_by_attr_and_attr2(val1, val2)  # <= search for sources
#   Source.where(attr: attr)                          # <= search for resources

##rename( new_source_name )     # <= set new name, and update all dependent attaches
##get_attaches                  # <= retrieve array of all instance attaches
#

module Cms
  module AdapterStable

    #
    # CREATE / SAVE / DELETE methods:
    #

    def initialize args
      super args
    end

    module ClassMethods
      def build(attributes={})
        raise ArgumentError, "expected an attributes Hash, got #{attributes.inspect}" unless attributes.is_a?(Hash)
        source_instance = Source.new(attributes)
        raise 'Source file with such name already exists!' if File.exists?(source_instance.get_source_filepath)
        if source_instance.target
          source_instance.name = source_instance.associated_name(source_instance.target)
        end
        if source_instance.attach
          attaches = source_instance.attach.is_a?(Array) ? source_instance.attach : [source_instance.attach]
          attaches.each do |a|
            a.attach_to(source_instance)
          end
        end
        begin
          set_data(source_instance.data)
        rescue
        end

        source_instance.flash!
        source_instance
      end
    end

    def flash!
      File.open(get_source_filepath, "w") { |file| file.write(data.to_s.force_encoding('utf-8'))  unless data.nil?}
    end

    def drop!
      get_source_attaches.each do |at|
        at.detach
      end
      File.delete(get_source_filepath)
    end

    def eliminate!
      get_source_attaches.each do |at|
        at.eliminate!
      end
      File.delete(get_source_filepath)
    end

    #
    # READ / WRITE  methods:
    #

    # touch file to read!
    def load!
      get_data
      self
    end
    # write data to file
    def set_data(data_arg)
      @self_data = data_arg
      self.data = data_arg
      flash!
    end
    # lazy file reading
    def get_data
      if @self_data == nil
        @self_data = File.exists?(self.get_source_filepath) ? File.read(self.get_source_filepath) : data
        self.data = @self_data
      end
      self.data = @self_data || ""
    end

    #
    #  NAMING METHODS:
    #

    def associated_name(target)
      target.type.to_s + TARGET_DIVIDER + target.get_source_name + TARGET_DIVIDER + get_source_name
    end

    def get_source_name
      self.name.include?(TARGET_DIVIDER) ? (self.name).split(TARGET_DIVIDER)[-1] : self.name
    end

    def get_source_filename
      self.name
    end

    def get_source_filepath
      raise ArgumentError, 'Name can not be blank!' if name.to_s.length==0 && target.nil?
      raise ArgumentError, 'Target name can not be blank!' if target && target.name.to_s.length==0
      get_source_folder.chomp('/') + '/' + get_source_filename
    end

    def get_source_folder
      self.path || AdapterStable.get_source_folder(type)
    end

    module ClassMethods
      def get_rails_env
        defined?(Rails).nil? ? 'test' : Rails.env
      end
      # Get source folder for any source type. Create, if not exists.
      def get_source_folder(type=nil)
        source_folder = ''
        if type==nil
          source_folder = get_rails_env == 'test' ? TEST_SOURCE_FOLDER : SOURCE_FOLDER
        else
          source_folder = get_rails_env == 'test' ? TEST_SOURCE_FOLDERS[type.to_i || SourceType::UNDEFINED] : SOURCE_FOLDERS[type.to_i || SourceType::UNDEFINED]
        end
        FileUtils.mkpath(source_folder) unless File.exists?(source_folder)
        source_folder
      end
    end

    #
    #  ASSOCIATIONS METHODS
    #

    def detach
      attaches = get_source_attaches
      !!File.rename(get_source_filepath, get_source_folder + get_source_name)
      self.name = get_source_name
      self.parent = nil
      attaches.each do |at|
        at.attach_to(self)
      end
    end

    def rename

    end

    def get_source_attach(source_type)
      source_folder = (AdapterStable.get_rails_env == 'test' ? TEST_SOURCE_FOLDERS[source_type] : SOURCE_FOLDERS[source_type])
      source_path = Dir.glob(source_folder + "/**/*#{type.to_i}#{TARGET_DIVIDER}#{get_source_name}#{TARGET_DIVIDER}*").flatten.compact
      source_path.length == 0  ? nil : AdapterStable.build_source(source_path[0])
    end

    def get_source_attaches
      source_attaches = []
      source_attaches << SourceType.all.collect{ |source_type| get_source_attach(source_type[1]) }
      source_attaches.flatten.compact
    end

    def attach_to(target_instance)
      old_filepath = get_source_filepath
      self.name = associated_name(target_instance)
      self.target = target_instance
      !!File.rename(old_filepath, get_source_filepath)
    end

    def get_source_target
      return nil unless get_source_filename.include?(TARGET_DIVIDER)
      target_type = get_source_filename.split(TARGET_DIVIDER)[0]
      target_name = get_source_filename[get_source_filename.index(TARGET_DIVIDER)+TARGET_DIVIDER.length .. get_source_filename.rindex(TARGET_DIVIDER)-1]
      target_folder = AdapterStable.get_source_folder(target_type)
      search_result = (Dir.glob(target_folder+"**/*#{TARGET_DIVIDER}#{target_name}") + Dir.glob(target_folder+"**/#{target_name}")).uniq
      raise 'more then 1 result for target' if search_result.size > 1
      raise 'target not found' if search_result.size == 0
      AdapterStable.build_source(search_result[0], target_type)
    end

    def get_target_type
      name.split(TARGET_DIVIDER)[0]
    end

    def get_target_name
      name.split(TARGET_DIVIDER)[1]
    end

    #
    #  FINDER METHODS
    #

    def get_source_id
      ID_PREFIX + self.type.to_s + ID_DIVIDER + get_source_name
    end

    module ClassMethods
      def method_missing(m, *args, &block)
        if m.to_s.index("find_source_by_") == 0
          attributes = m["find_source_by_".size..-1].split("_and_")
          raise "Attributes count expected: #{attributes.size}, got: #{args.size}" unless attributes.size == args.size
          match_hash = {}
          attributes.each_with_index {|attr, index| match_hash[attr.to_sym] = args[index]}
          return AdapterStable.where(match_hash)
        else
          puts "There's no method called #{m} here -- please try again with args #{args}"
        end
      end
      def where(attributes)
        raise ArgumentError, "expected an attributes Hash, got #{attributes.inspect}" unless attributes.is_a?(Hash)
        AdapterStable.all.select do |source|
          match = true
          attributes.each{|key, val|
            key = :'get_source_name' if key == :'name'
            match = false if source.send(key) != val
          }
          match
        end
      end
      def all
        env = get_rails_env
        (env == 'test' ? TEST_SOURCE_FOLDERS : SOURCE_FOLDERS).map {|key_type, val| AdapterStable.all_by_type(key_type) }.reject { |ar| ar.empty? }.flatten
      end
      def all_by_type source_type
        files = Array.new
        dir = AdapterStable.get_source_folder(source_type)
        Dir.glob(dir+"**/*").each do |f|
          s = build_source(f, source_type)
          files.push(s) unless s.nil?
        end
        files
      end
      def parse_path(path)
        filename = path.split('/').last
        source_type = SourceType::UNDEFINED
        (get_rails_env == 'test' ? TEST_SOURCE_FOLDERS : SOURCE_FOLDERS).map {|key_type, val| source_type = key_type if path.include?(val) }
        {source_type: source_type, filename: filename}
      end
      def build_source(filepath, source_type=nil)
        if source_type == nil
          source_type = parse_path(filepath)[:source_type]
        end
        s = Source.new({ type: source_type, name: filepath.split('/').last, data: nil, path: File.dirname(filepath)+'/' })
        begin
          s.filename = s.get_source_filename
          s.path = s.get_source_folder
          target_object = s.get_source_target
          s.target = target_object unless target_object.nil?
        rescue
          return nil
        end
        s
      end
      def get_source_by_id(id)
        id = id[ID_PREFIX.size .. -1]
        type, name = id.split(ID_DIVIDER)
        find_source_by_name_and_type(name, type.to_i).first
      end
    end
    extend ClassMethods
  end
end