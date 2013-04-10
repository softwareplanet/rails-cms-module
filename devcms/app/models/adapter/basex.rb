module ActiveFile
  require 'ostruct'

  class Basex < OpenStruct
    include Adapterx
    extend Adapterx::ClassMethods

    def type
      class_name = self.class.to_s
      class_name.index("::").nil? ? class_name.downcase : class_name.split("::")[1].downcase
    end

    def self.child_of(parent_name)
      parent_class = parent_name.to_s.camelize.safe_constantize
      raise "#{parent_name.to_s.camelcase} not defined." if parent_class == nil
      @@parent_class = parent_name
    end

    def self.parent_to(child_name)
      child_class = child_name.to_s.camelize.safe_constantize
      raise "#{child_name.to_s.camelcase} not defined." if child_name == nil
      @@child_name = child_name
    end

    def method_missing(m, *args, &block)
      true
    end
    
  end
end