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

  # Basic ActiveFile syntax validator. To prevent errors, that can potentially appears, set STRONG_VALIDATOR constant to true
  #
  module Syntax

    STRONG_VALIDATOR = false

    # Warning constants:

    WARNING_LAZY_PARENT_NAME = {code:1, description:'You have specified, that your model belongs to %s model. But, it seems that name of parent model instance was not specified. It may leads to problems with object saving.'}

    # Error constants:

    OBJECT_NAME_REQUIRED = {code:-1, description:'Object name required for class: %s'}
    AMBIGUOUS_FILE_SEARCH_RESULT = {code:-1, description:'Two different file objects pointed to the same logic object: %s'}

    class SyntaxValidator
      def self.syntax_warning(arg, warning_type)
        warning = warning_type[:description] % arg
        STRONG_VALIDATOR ? raise(warning) : puts("[SyntaxValidator]==>WARNING\n==>"+warning)
      end
      def self.syntax_error(arg, error_type)
        error = error_type[:description] % arg
        raise("[SyntaxValidator]==>ERROR\n==>" + error + "\nIn Stack:\n")
      end
    end
  end

  # Dependency module contain definitions for dependency relationships between objects
  #
  module DependencyDefinition

    # Available relationships:

    HAS_ONE = :has_one
    HAS_MANY = :has_many
    BELONGS_TO = :belongs_to

    # Class, defines simple dependency struct, that describes association between two objects
    #
    class DependencyClass
      attr_accessor :dependency_type, :dependency_owner, :dependency_target
      def initialize(dependency_type, dependency_owner, dependency_target)
        @dependency_type, @dependency_owner, @dependency_target = dependency_type, dependency_owner, dependency_target
      end
    end

    # Class, that extends DependencyClass with information about dependency_target instance
    #
    class RelationObject
      attr_accessor :relation_object, :dependency_class
      def initialize(relation_object, dependency_class)
        @relation_object, @dependency_class = relation_object, dependency_class
      end
    end

    # Class, simple object definition, that describes instance class and instance name
    #
    class ObjectDefinition
      attr_accessor :object_class, :object_name
      def initialize(object_class, object_name)
        @object_class, @object_name = object_class, object_name
      end
    end

    # Defines overriden, non-default location for class instances. Example:  file_path './some/location'
    #
    class ClassObjectsLocation
      attr_accessor :class_name, :location_directory
      def initialize(class_name, location_directory)
        @class_name, @location_directory = class_name, location_directory
      end
    end
  end

  # Module, contains logic that operate with dependency objects
  #
  module DependencyAction

    # Helper class, that know dependency rules, and can operate with objects relationships
    #
    class AssociationManager

      # Bind relative objects. Parameters, passed to ActiveFile constructor, can include useful associations, and this one parses them.
      def self.initialize(object, hash_parameters)
        if hash_parameters
          hash_parameters.each { |dependency_target, dependency_object|
            association = get_associations(object, dependency_target, nil)
            build_association(object, association[0].dependency_target, association[0].dependency_type, dependency_object) if association.any?
          }
        end
      end

      # Get relation object

      def self.get_relation_object(owner, relation_name)
        association = get_associations(owner, relation_name.singularize.camelize, nil)
        if association[0].dependency_type == BELONGS_TO
          PathBuilder.get_assoc_objects(owner)

          # get relation object simple, from file path:
          #filepath = Finder.find_by_name(owner.class, owner.name)
          #filepath.split(TARGET_DIVIDER)[2]
        end


        owner.get_file_path
        puts 'test'
      end

      # Store association information for object

      def self.build_association(dependency_owner, dependency_target, dependency_type, relation_object)
        dependency_owner.relation_objects ||= []

        Syntax::SyntaxValidator.syntax_warning(dependency_target, Syntax::WARNING_LAZY_PARENT_NAME) if dependency_type == Dependency::BELONGS_TO && relation_object.name.nil?

        dependency_association = Dependency::DependencyClass.new(dependency_type, dependency_owner.class.to_s, dependency_target)
        relation = Dependency::RelationObject.new(relation_object, dependency_association)
        dependency_owner.relation_objects.push(relation)
      end

      # Search for associations array

      def self.get_associations(dependency_owner, dependency_target, dependency_type)
        ActiveFile::Base.get_dependency_classes.select{ |e|
          owner_eq = dependency_owner ? e.dependency_owner ==  dependency_owner.class.to_s.camelize : true
          target_eq = dependency_target ? e.dependency_target.to_s.camelize == dependency_target.to_s.camelize : true
          type_eq = dependency_type ? e.dependency_type == dependency_type : true
          owner_eq && target_eq && type_eq
        }.compact
      end

      def self.get_belongs_to_association(object)
        self.get_association(object, BELONGS_TO)
      end
      def self.get_has_one_association(object)
        self.get_association(object, HAS_ONE)
      end
      def self.get_has_many_associations(object)
        self.get_association(object, HAS_MANY)
      end
      def self.get_parents(object)
        self.get_association(object, BELONGS_TO)
      end
      def self.get_childrens(object)
        self.get_association(object, [HAS_MANY, HAS_ONE])
      end
      def self.get_association(object, dependency_type)
        return [] if object.relation_objects.blank?
        dependency_type = [dependency_type] unless dependency_type.is_a?(Array)
        object.relation_objects.collect { |rel|
          rel.relation_object if dependency_type.include?(rel.dependency_class.dependency_type)
        }.compact
      end
    end

    # File path and file name manipulation logic composing is here:

    ASSOC_DELIMITER = '-tar-'
    SIMPLE_DELIMITER = '-'
    EXTENSION_DELIMITER = '-ext-'
    BASE_FOLDER = './file_base/'

    class PathBuilder
      def self.get_raw_single_class(object)
        object.is_a?(Class) ? object.to_s.downcase : object.class.to_s.singularize.downcase
      end
      def self.get_raw_multi_class(object)
        object.is_a?(Class) ? object.to_s.pluralize.downcase : object.class.to_s.pluralize.downcase
      end
      def self.get_raw_object_name(object)
        object.name ? object.name.gsub('.', EXTENSION_DELIMITER) : Syntax::SyntaxValidator.syntax_error(object, Syntax::OBJECT_NAME_REQUIRED)
      end
      def self.build_file_name(object)
        parents = AssociationManager.get_parents(object)
        associations_appender = parents.collect do |parent_object|
          ASSOC_DELIMITER + get_raw_single_class(parent_object) + SIMPLE_DELIMITER + get_raw_object_name(parent_object)
        end
        extension = object.name.split('.')[1].to_s
        extension = '.' + extension  unless extension.blank?
        object.name.split('.')[0] + associations_appender.join + extension.to_s
      end
      def self.build_file_path(object, overriden_base_folder = nil)
        file_name = build_file_name(object)
        file_folder = build_class_path(object.class, overriden_base_folder)
        file_folder + '/' + file_name
      end
      def self.build_class_path(object_class, overriden_base_folder = nil)
        base_folder = overriden_base_folder || BASE_FOLDER
        file_folder = base_folder + get_raw_multi_class(object_class)
        FileUtils.mkpath(file_folder) unless File.exists?(file_folder)
        file_folder
      end
    end

    # Class, that uses for parsing

    class PathParser
      def self.get_assoc_objects(object)
        file_path = Finder.find_by_name(object.class, object.name).filepath
        return [] unless file_path.include?(ASSOC_DELIMITER)
        file_path
        assoc_objects=[]
        file_path.split(TARGET_DIVIDER)[1..-1].each do |class_name_pair|
          obj_class
          obj_name
          assoc_objects.push(Dependency::ObjectDefinition.new(obj_class, obj_name))
        end


        file_path.split(TARGET_DIVIDER)[2]

      end
    end

    # Finder

    class Finder
      def self.find_by_name(class_class, search_term)
        overriden_base_folder = class_class.get_overriden_locations.select{|col| col.location_directory if col.class_name == class_class.to_s}.compact.first
        file_path = Dependency::PathBuilder.build_class_path(class_class, overriden_base_folder)

        search_name, search_extension = search_term.split('.')
        search_extension.prepend('.') if search_extension
        search_extension = search_extension.to_s

        files = Dir.glob("#{file_path+'/'+search_name+search_extension}") + Dir.glob("#{file_path+'/'+search_name}#{ASSOC_DELIMITER}*"+search_extension)
        return nil if files.empty?
        Syntax::SyntaxValidator.syntax_error(files, Syntax::AMBIGUOUS_FILE_SEARCH_RESULT) if files.size > 1
        return class_class.new(name: search_name+search_extension, filepath: files[0])
      end
    end

  end # module Dependency

  class Base < OpenStruct
    require 'active_support/inflector'

    @@dependency_classes = []
    @@overriden_locations = []

    attr_accessor :relation_objects

    # ActiveFile constructor can take different types of input parameters: name, associations and properties
    # Name is required for file object if you want save it, because file name should be specified
    # Life period of Properties is not persistent
    # Associations is persistent, of course if you don't forget to call 'save' for object
    # Associations and Properties can be assigned later, not necessarily in the constructor
    #
    # Example:
    #
    #  class A          class B            class C
    #    has_one :b       belongs_to :a      belongs_to :a
    #    has_many :c      has_may :c         belongs_to :b
    #
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

    def initialize(hash=nil)
      # Let Open Struct to populate it's internal state:
      super(hash)
      # And bind relative objects, if was specified
      Dependency::AssociationManager.initialize(self, hash)
    end

    def self.get_dependency_classes;
      @@dependency_classes
    end

    def self.get_overriden_locations
      @@overriden_locations
    end

    # Get (relative) file path of ActiveFile instance
    #
    def get_file_path
      raise 'File name not specified' if name.nil?
      Dependency::PathBuilder.build_file_path(self)
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
      Dependency::Finder.find_by_name(self, name)
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
    #def inspect
    #  "asasdasd!!"
    #end
    def type
      class_name = self.class.to_s
      class_name.index("::").nil? ? class_name.downcase : class_name.split("::")[1].downcase
    end

    def self.type
      class_name = self.to_s
      class_name.index("::").nil? ? class_name.downcase : class_name.split("::")[1].downcase
    end

    def self.belongs_to(parent_name)
      @@dependency_classes.push(ActiveFile::Dependency::DependencyClass.new(ActiveFile::Dependency::BELONGS_TO, self.to_s, parent_name.to_s.camelize))
    end

    def self.has_one(child_name)
      @@dependency_classes.push(ActiveFile::Dependency::DependencyClass.new(ActiveFile::Dependency::HAS_ONE, self.to_s, child_name.to_s.camelize))
    end

    def self.has_many(child_name)
      @@dependency_classes.push(ActiveFile::Dependency::DependencyClass.new(ActiveFile::Dependency::HAS_MANY, self.to_s, child_name.to_s.singularize.camelize))
    end

    def self.file_path(overriden_file_path)
      @@overriden_locations.push(ActiveFile::Dependency::ClassObjectsLocation.new(self.to_s, overriden_file_path))
    end

    # Extend model with dependency-relation methods

    def method_missing(method, *args, &block)
      if (super_result = super(method, *args, &block)) == nil
        method_name, method_chomps = method.id2name, method.id2name.chomp('=')
        len = args.length
        association = Dependency::AssociationManager.get_associations(self, method_chomps, nil)
        if association.any?
          super_result = Dependency::AssociationManager.get_relation_object(self, method_chomps)
          if method_name.include?('=') && method != :[]=
            raise ArgumentError, "wrong number of arguments (#{len} for 1)", caller(1) if len != 1
            modifiable[new_ostruct_member(method_chomps)] = args[0]
          elsif len == 0 && method != :[]
            @table[method] = super_result
          else
            raise NoMethodError, "undefined method #{method} for #{self}", caller(1)
          end
        end
      end
      super_result
    end

    #  method = m[-1] == '=' ? m[0..-2] : m
    #  operator = m[-1] == '=' ? '=' : ''
    #  dependency = @@dependency_classes.select{ |e|
    #    e.dependency_target.to_s.camelize == method.to_s.singularize.camelize &&
    #    e.dependency_owner.to_s.camelize ==  self.class.to_s.camelize
    #  }
    #
    #  args = nil
    #  super(m, args) if dependency.empty?
    #
    #  #raise "Adapter request for #{m}" if dependency.empty?
    #  #return Adapter.method_missing(m, args, block) if dependency.empty?
    #  if operator == '='
    #    lvalue = method_getter(dependency.first)
    #    lvalue = nil if lvalue.empty?
    #    rvalue = args.first
    #    method_setter(lvalue, rvalue)
    #  else
    #    method_getter(dependency.first)
    #  end
    #end

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