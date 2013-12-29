module Cms
  class SiteLocal < ActiveRecord::Base
    attr_accessible :tag_id, :text, :language
  end
end