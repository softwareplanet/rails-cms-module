# Stable version of Adapter
#
# Methods:
#
#   attach_to( source )           # <= attach source to parent
#   detach                        # <= detach source from parent
#   get_name                      # <= self name, without -tar- etc
#   rename( new_source_name )     # <= set new name, and update all dependent attaches
#   get_attaches                  # <= retrieve array of all instance attaches
#

module Cms
  module Adapter

    #
    def save!
      fp = get_source_folder.chomp('/')+'/'+name
      File.open(fp, "w") do
        |file| file.write(data.force_encoding('utf-8'))
      end
    end

    def data
      if @self_data == nil
        fp = get_source_folder.chomp('/')+'/'+name
        @self_data = File.read(fp)
      end
      @self_data || ""
    end

    def get_source_path
      raise ArgumentError, 'Name can not be blank!' if name.to_s.length==0 && target.nil?
      raise ArgumentError, 'Target name can not be blank!' if target && target.name.to_s.length==0
      get_source_folder.chomp('/') + '/' + get_filename
    end

    # Allows nested sources
    def attach_to parent
      load!
      delete!
      self_name = self.name.include?(TARGET_DIVIDER) ? (self.name).split(TARGET_DIVIDER)[-1] : self.name
      self.name = parent.type.to_s + TARGET_DIVIDER + parent.name + TARGET_DIVIDER + self_name.to_s
      Source.create(:type => self.type, :name => self.name, :data => data)
      self.target = parent
      self
    end

    def detach
      !!File.rename(get_source_path, get_source_folder + get_self_name)
      self.parent = nil
    end

    def get_name
      self_name = self.name.include?(TARGET_DIVIDER) ? (self.name).split(TARGET_DIVIDER)[-1] : self.name
    end

    def rename new_source_name
      get_attaches.each do |attach|
        name_parts = attach.name.split(TARGET_DIVIDER)
        new_name = name_parts[0] + TARGET_DIVIDER + new_source_name + TARGET_DIVIDER + name_parts[2]
        !!File.rename(source.get_source_path, get_source_folder + new_name)
      end
      name = name.include?(TARGET_DIVIDER) ?
          name.split(TARGET_DIVIDER)[0]+TARGET_DIVIDER+name.split(TARGET_DIVIDER)[1]+TARGET_DIVIDER+new_source_name :
          new_source_name
      !!File.rename(source.get_source_path, get_source_folder + name)
    end

    def get_target
      return nil unless name.include?(TARGET_DIVIDER)
      target_type = get_target_type
      target_name = get_target_name
      target =  Adapter.get_source_folder(target_type) + target_name
      return nil unless File.exists?(target)
      return Source.new({ :type => target_type.to_i, :name => target_name, :data => nil })
    end

    def get_target_type
      name.split(TARGET_DIVIDER)[0]
    end
    def get_target_name
      name.split(TARGET_DIVIDER)[1]
    end

    # Get attached object
    def get_attach type
      results = Adapter.all_by_type(type).select do |source|
        # can increase speed by Dir.glob(dir+"**/*") mask specify:
        source.name.include?(TARGET_DIVIDER+get_name+TARGET_DIVIDER)
      end
      results[0]
    end

    def get_attaches
      self_name = get_name
      # can increase speed by Dir.glob(dir+"**/*") mask specify:
      Adapter.all.select do |source|
        source.get_target_name == self_name && source.get_target_type == self.type
      end
    end

    #
    # STATIC METHODS MODULE
    module ClassMethods
      def all_by_type source_type
        files = Array.new
        dir = Adapter.get_source_folder(source_type)
        Dir.glob(dir+"**/*").each do |f|
          s = Source.new({ type: source_type, name: f.split('/').last, data: nil, path: File.dirname(f)+'/' })
          target_object = s.get_target
          s.target = target_object unless target_object.nil?
          files.push(s)
        end
        files
      end
      def all
        env = defined?(Rails).nil? ? 'test' : Rails.env
        (env == 'test' ? TEST_SOURCE_FOLDERS : SOURCE_FOLDERS).map {|key_type, val| Adapter.all_by_type(key_type) }.reject { |ar| ar.empty? }.flatten
      end
    end

  end
end
