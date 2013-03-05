module Aloha::Rails
  class Railtie < ::Rails::Railtie
    initializer 'aloha-rails.initialize' do
      ActiveSupport.on_load(:action_view) do
        include Aloha::Rails::Helpers
      end
    end
  end
end
