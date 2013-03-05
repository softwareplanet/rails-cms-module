require "devcms/engine"
require "devcms/modules"

module Devcms
  class Engine < Rails::Engine
    engine_name :devcms

    rake_tasks do
      #load "tasks/devcms_tasks.rake"
    end

  end
end
