module Cms
  module SourceType
    UNDEFINED = 0
    LAYOUT = 1
    CONTENT = 2
    CSS = 3
    SEO = 4
    IMAGE = 6
    COMPILED = 7
    LAYOUT_SETTINGS = 9
    ORDER = 10
    HEAD = 11
    CMS_SETTINGS = 12

    def self.all
      SourceType.constants.collect{|name| {name => self.class_eval(name.to_s) }}.inject(&:merge)
    end


  end
end
