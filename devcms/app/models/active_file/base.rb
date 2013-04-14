#
# ActiveFile = base.rb: lightweight file system ORM implementation
#
# Author:: Vitaly Pestov
# Department:: InterLink LLC, Ukraine, 2013
#
# Build a persistent domain model by mapping file system objects to Ruby classes.
# It inherits ActiveRecord-similar interface.
#
module ActiveFile # v0.01: <active_support-required version>
  #
  # Based on Yukihiro Matsumoto's OpenStruct implementation,
  # to extend ActiveFile objects with arbitrary attributes
  require 'ostruct'
  require 'active_support/core_ext/object/blank'

  module Dependency
    HAS_ONE = :has_one
    HAS_MANY = :has_many
    BELONGS_TO = :belongs_to

    # Defines dependency between two classes and type of their association

    class DependencyClass
      attr_accessor :dependency_type, :dependency_owner, :dependency_target
      def initialize(dependency_type, dependency_owner, dependency_target)
        @dependency_type, @dependency_owner, @dependency_target = dependency_type, dependency_owner, dependency_target
      end
    end

    # Defines association, related to single class instance

    class RelationObject
      attr_accessor :relation_object, :dependency_class
      def initialize(relation_object, dependency_class)
        @relation_object, @dependency_class = relation_object, dependency_class
      end
    end
  end # module Dependency

  class Base < OpenStruct
    require 'active_support/inflector'

    @@dependency_classes = []

    attr_accessor :relation_objects

    # ActiveFile constructor can take different types of input parameters: name, associations and properties
    # Name is required for file object if you want save it, because file name should be specified
    # Life period of Properties is not persistent
    # Associations is persistent, of course if you don't forget to call 'save' for object
    # Associations and Properties can be assigned later, not necessarily in the constructor
    #
    # Example:
    #
   #models/author.rb:
    #
    #  class Author < ActiveFile::Base
    #    has_one :profile
    #    has_many :articles
    #  end
    #
   #models/profile.rb:
    #
    #  class Profile < ActiveFile::Base
    #    belongs_to :author
    #  end
    #
   #models/article.rb
    #
    #  class Article < ActiveFile::Base
    #    belongs_to :author
    #  end
    #
   ###
    #  author = Author.new(name: 'Joe')
    #
    #  profile = Profile.new(name: 'Joe_profile')
    #  author = Author.new(name: 'Joe' , profile: profile )
    #
    #  article_1 = Article.new(name: 'article_1')
    #  article_2 = Article.new(name: 'article_2' , :author => author)
    #  author = Author.new(name: 'Joe' , articles: [article_1, article_2])
    #
    #  author.profile = profile
    #
    #  etc....

    BASE_FOLDER = './file_base/'

    def get_base_folder
      self.base_folder || ActiveFile::Base::BASE_FOLDER
    end

    # Get (relative) file path of ActiveFile instance
    #
    def get_file_path
      raise 'File name not specified' if name.nil?

      # Source folder for non-associated instances is a folder with Classified name
      file_path=get_base_folder+self.class.to_s.pluralize.downcase+'/'

      belongs_to_association = AssociationManager.get_belongs_to_association(self)
      if belongs_to_association
        file_path+=belongs_to_association.dependency_class.dependency_target.to_s.pluralize.downcase+relation_object.name+'/'
      end
      FileUtils.mkpath(file_path) unless File.exists?(file_path)
      file_path+name
    end

    # Save ActiveFile instance to file system object
    #
    def save
      encoded_data = self.data.nil? ? '' : self.data.force_encoding('utf-8')
      ::File.open(get_file_path, 'w') { |file| file.write(encoded_data) }
    end

    # Reload file data
    #
    def reload!
      self.data = ::File.read(get_file_path)
    end

    # Lazy file data retrieving
    #
    def get_data
      data = ::File.read(get_file_path) if data.nil?
      data
    end

    # Write file data
    #
    def set_data(file_content=nil)
      self.data = file_content unless file_content.nil?
      save
    end

    # Find ActiveFile object by name:
    #
    def self.find(name)
      object = self.new(name: name)
      File.exists?(object.get_file_path) ? object.bind_associations : nil
    end

    # Bind associations
    #
    def bind_associations
      @@dependency_classes.select do |e|
        if e.dependency_owner.to_s.camelize ==  self.class.to_s.camelize
          dependency_target, dependency_class = e.dependency_target, e.dependency_class
          dependency_class.constantize.new()
          data_point.send("queued?=",false)
          e.dependency_target.new()#???????????
        end
      end


      # object can be type of Array, for :has_many association. Make type cast:
      object_array = object.is_a?(Array) ? object : [object]
      object_array.each do |obj|
        dependency = get_dependency_for_target_class(obj.class)
        raise "No one dependency rule <has/belongs> were specified between owner #{self} and target #{obj}" if dependency.nil?
        relation = Dependency::RelationObject.new(obj, dependency)
        @relation_objects ||= []
        @relation_objects.push(relation)
      end
    end

    #def initialize(*args)
=begin
      args.each do |arg|
        case arg
          when String
            @short_name = arg if arg.is_a?(String)
          when Hash
            key, value = arg.to_a.first[0], arg.to_a.first[1]
            @short_name = value if key == :name
            const_name = key.to_s.singularize.camelize
            if Object.const_defined?(const_name)
              # for {:associated_object => @instantiated_dependency}
              #bind_associated_object(value) if has_dependency_target_class?(const_name.constantize)
            end
        end
      end
      #raise "#{type.camelize} object should be initialized with some name. For example: User.new('Joe') or User.new(:name => 'Joe')" if @short_name.blank?
      raise "#{type.camelize} named '#{@short_name}' already exists. Use dynamic finder." unless new_record?
=end
    #  args = args[0] if args.is_a?(Array)
    #  super args
    #end
=begin
    # Bind associated dynamic object to this instance

    def bind_associated_object(object)
      # object can be type of Array, for :has_many association. Make type cast:
      object_array = object.is_a?(Array) ? object : [object]
      object_array.each do |obj|
        dependency = get_dependency_for_target_class(obj.class)
        raise "No one dependency rule <has/belongs> were specified between owner #{self} and target #{obj}" if dependency.nil?
        relation = Dependency::RelationObject.new(obj, dependency)
        @relation_objects ||= []
        @relation_objects.push(relation)
      end
    end
=end

    def get_dependency_for_target_class(target_class)
      dependency = @@dependency_classes.select{ |e|
        e.dependency_owner.to_s.camelize ==  self.class.to_s.camelize &&
        e.dependency_target.to_s.camelize == target_class.to_s.camelize
      }
      dependency.any? ? dependency[0] : nil
    end
    def get_dependency_objects(dependency)
      @relation_objects.collect{ |r|
        r.relation_object if r.dependency_class == dependency
      }.compact
    end
    def has_dependency_target_class?(target_class)
      !get_dependency_for_target_class(target_class).nil?
    end
    def new_record?
      true
    end
    #def delete_method(raise_exception_on_error)
    #  delete_file_name = get_source_path
    #  ::File.delete(delete_file_name)
    #end
    def inspect
      "asasdasd"
    end
    def type
      class_name = self.class.to_s
      class_name.index("::").nil? ? class_name.downcase : class_name.split("::")[1].downcase
    end

    def self.type
      class_name = self.to_s
      class_name.index("::").nil? ? class_name.downcase : class_name.split("::")[1].downcase
    end

    def self.belongs_to(parent_name)
      dependency_target = parent_name.to_s.camelize.safe_constantize
      raise "#{parent_name.to_s.camelcase} not defined." if dependency_target == nil
      @@dependency_classes.push(ActiveFile::Dependency::DependencyClass.new(ActiveFile::Dependency::BELONGS_TO, self.to_s, dependency_target))
    end

    def self.has_one(child_name)
      dependency_target = child_name.to_s.camelize.safe_constantize
      raise "#{child_name.to_s.camelcase} not defined." if dependency_target == nil
      @@dependency_classes.push(ActiveFile::Dependency::DependencyClass.new(ActiveFile::Dependency::HAS_ONE, self.to_s, dependency_target))

      #--TODO: Here is I attempted to create dependency-named method dynamically. It is failed. I commented it out, to research this feature in future (VitalyP).
      #@@dependency_target_transfer_variable = dependency_target
      # singleton_class = class << self; self; end
      # singleton_class.send(:define_method, @@dependency_target_transfer_variable.to_s.to_sym) do
      #   return "Method added"
      #end
    end

    def self.has_many(child_name)
      dependency_target = child_name.to_s.singularize.camelize.safe_constantize
      raise "#{child_name.to_s.camelcase} not defined." if dependency_target == nil
      @@dependency_classes.push(ActiveFile::Dependency::DependencyClass.new(ActiveFile::Dependency::HAS_MANY, self.to_s, dependency_target))
    end

    def __method__missing(m, *args, &block)
      method = m[-1] == '=' ? m[0..-2] : m
      operator = m[-1] == '=' ? '=' : ''
      dependency = @@dependency_classes.select{ |e|
        e.dependency_target.to_s.camelize == method.to_s.singularize.camelize &&
        e.dependency_owner.to_s.camelize ==  self.class.to_s.camelize
      }
      raise "Adapter request for #{m}" if dependency.empty?
      #return Adapter.method_missing(m, args, block) if dependency.empty?
      if operator == '='
        lvalue = method_getter(dependency.first)
        lvalue = nil if lvalue.empty?
        rvalue = args.first
        method_setter(lvalue, rvalue)
      else
        method_getter(dependency.first)
      end
    end

    def method_setter(lvalue, rvalue)
      #--TODO: maybe it is good idea to provide 'vise versa' capability of the dependency definition?
      dependency = @@dependency_classes.select{ |e|
        e.dependency_owner.to_s.camelize == self.class.to_s.camelize && e.dependency_target.to_s.camelize == rvalue.class.to_s.camelize
      }
      raise "Dependency parenthood from #{lvalue.class} to #{rvalue.class} is not defined." if dependency.empty?
      self.set_attach(rvalue)

      #if lvalue.nil?
      #  # dependency not yet assigned
      #
      #end
      #raise "Dependency parenthood from #{lvalue.class} to #{rvalue.class} is not defined."

    end

    # Get dependency object
    def method_getter(dependency)
      owner_cname = dependency.dependency_owner
      owner_class = owner_cname.safe_constantize
      target_cname = dependency.dependency_target.to_s
      target_class = target_cname.safe_constantize
      dependency_type = dependency.dependency_type
      object =
          case dependency_type
            when ActiveFile::Dependency::HAS_ONE
              object_in_array = self.get_dependency_objects(dependency)
              object_in_array.any? ? object_in_array[0] : nil
            when ActiveFile::Dependency::HAS_MANY
              object_in_array = self.get_dependency_objects(dependency)
              object_in_array
            when ActiveFile::Dependency::BELONGS_TO
              object_in_array = self.get_dependency_objects(dependency)
              object_in_array.any? ? object_in_array[0] : nil
            else
              nil
          end
      object
    end

    # Main rule to link attaches with their targets
    #
    def attach_my_name!
      # Is we an attached instance?
      unless ::File.exists?(self.get_source_folder + self.name)
        dependency = @@dependency_classes.select{ |e| e.dependency_target.to_s.camelize == self.class.to_s.camelize }
        unless dependency.empty?
          dependency = dependency.first
          owner_cname = dependency.dependency_owner
          owner_class = owner_cname.safe_constantize
          target_cname = dependency.dependency_target.to_s
          target_class = target_cname.safe_constantize
          dependency_type = dependency.dependency_type
          file_name = Dir.glob("#{folder+name}*")
          new_name = self.name + TARGET_DIVIDER + owner_cname.downcase + TARGET_DIVIDER + owner_class.to_s
          raise "file not found #{self.name}" if ::File.exists?(get_source_folder + new_name)
          self.name = new_name
        end
        raise "file not found #{self.name}" if ::File.exists?(get_source_folder + self.name)
      end
      self.name
    end


    def self.is_target?(filename)
      filename.split(TARGET_DIVIDER).size == 3
    end
    def self.cut_name(filename)
      filename.split(TARGET_DIVIDER)[0]
    end
    def self.cut_dependency_class(filename)
      raise 'not target in cut_dependency_class method' unless self.is_target?(filename)
      filename.split(TARGET_DIVIDER)[1]
    end
    def self.cut_dependency_name(filename)
      raise 'not target in cut_dependency_name method' unless self.is_target?(filename)
      filename.split(TARGET_DIVIDER)[2]
    end
    def self.transformFileToObject(filename)
      active_file_name = cut_name(filename)
      self.type.camelize.constantize.new(active_file_name)
    end

    # Finders Methods
    #
    def self.find_by_name(name)
      folder = get_source_folder(self.type)
      files = Dir.glob("#{folder+name}*")
      activeFiles = []
      files.each do |file|
        unless file.end_with?(name)
          raise ""
        end
        file = file.split('/')[-1]
        activeFiles.push(transformFileToObject(file))
      end
      return activeFiles
    end
  end
end