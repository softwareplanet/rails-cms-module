require "cms/engine"
require "cms/modules"

module Cms
  class Engine < Rails::Engine
    engine_name :cms

    rake_tasks do
      #load "tasks/cms_tasks.rake"
    end

  end
end
