require "softwareplanet-cms/engine"
require "softwareplanet-cms/modules"

module Devcms
  class Engine < Rails::Engine
    engine_name :cms

    rake_tasks do
      #load "tasks/cms_tasks.rake"
    end

  end
end
