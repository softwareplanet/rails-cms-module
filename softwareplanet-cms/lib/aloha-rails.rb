require "aloha-rails/version"
require "aloha-rails/railtie" if defined?(::Rails)
require "aloha-rails/engine"  if defined?(::Rails)

module Aloha
  module Rails

    autoload :Helpers, 'aloha-rails/helpers'

    mattr_accessor :default_plugins
    self.default_plugins = %w(common/format common/list common/link common/block common/undo common/contenthandler common/paste)
  end
end
