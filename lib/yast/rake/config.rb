require 'yast/rake/config/base'
require 'yast/rake/config/yast'
require 'yast/rake/config/package'
require 'yast/rake/config/console'
require 'yast/rake/context'
require 'pathname'

module Yast
  module Rake
    module Config

      LOCAL_CONFIG_DIR = File.join('rake', 'configs')

      extend Context

      attr_accessor :verbose, :trace

      def config
        Config.get_module_context
      end

      def self.extended(object)
        register Base, false
        register Yast
        register Package
        register Console
      end

      def self.load_custom_modules
        Dir.glob("#{config.root.join(LOCAL_CONFIG_DIR)}/*.rb").each do |config_file|
          require config_file
        end
      end

      private

      def self.config
        Config.context.config
      end

    end
  end
end

