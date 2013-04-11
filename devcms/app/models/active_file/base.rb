module ActiveFile # v0.01: <active_support-required version>
  require 'ostruct'
  require 'active_support/core_ext/object/blank'

  module Dependency
    HAS_ONE = "has_one";
    HAS_MANY = "has_many";
    BELONGS_TO = "belongs_to";
    class DependencyClass
      attr_accessor :dependency_type,:dependency_owner,:dependency_target
      def initialize(dependency_type, dependency_owner, dependency_target)
        @dependency_type = dependency_type
        @dependency_owner = dependency_owner
        @dependency_target = dependency_target
      end
    end
  end

  #module Relation
  #  attr_accessor :dependency_type, :dependency_target
  #  def initialize(dependency_type, dependency_target)
  #    @dependency_type = dependency_type
  #    @dependency_target = dependency_target
  #  end
  #end

  # This class defines ActiveFile functionality
  class Base < OpenStruct
    require "active_support/inflector"

    @@dependency_classes = []
    #@relations = {}
    @short_name = ''

    def initialize(*args)
      args.each do |arg|
        @short_name = arg if arg.is_a?(String)
        if arg.is_a?(Hash)
          key, value = arg.to_a.first[0], arg.to_a.first[1]
          @short_name = value if key==:name
        end
      end
      raise "#{type.camelize} object should be initialized with some name. For example: User.new('Joe') or User.new(:name => 'Joe')" if @short_name.blank?
      raise "#{type.camelize} named '#{@short_name}' already exists. Use dynamic finder." unless new_record?
    end
    def new_record?
      true
    end
    def save
    end
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
      @@dependency_classes.push(ActiveFile::Dependency::DependencyClass.new(ActiveFile::Dependency::HAS_ONE, self.to_s, dependency_target))
    end

    def method_missing(m, *args, &block)
      method = m[-1] == '=' ? m[0..-2] : m
      operator = m[-1] == '=' ? '=' : ''
      i = 0
      dependency = @@dependency_classes.select{ |e|
        e.dependency_target.to_s.camelize == method.to_s.camelize &&
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
              self.get_attaches_by_class_name(target_class)
            when ActiveFile::Dependency::BELONGS_TO
              self.get_attaches_by_class_name(target_class)
            else
              nil
          end
      attach
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