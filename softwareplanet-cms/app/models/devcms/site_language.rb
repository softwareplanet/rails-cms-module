module Devcms
  class SiteLanguage < ActiveRecord::Base
    attr_accessible :name, :url
    validates :name, :presence => true, :uniqueness => true
  end
end
