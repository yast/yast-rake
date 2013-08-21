require 'yast/rake/config'
require 'yast/rake/command/console'

module Yast
  module Rake
    module Command

      LOCAL_COMMAND_DIR = File.join('rake', 'commands')

      extend Context

      attr_accessor :verbose, :trace

      def command
        Command.get_module_context
      end

      def self.extended(object)
        register Console
      end

      def self.load_custom_modules
        Dir.glob("#{config.root.join(LOCAL_COMMAND_DIR)}/*.rb").each do |command_file|
          require command_file
        end
      end

      private

      def self.config
        Config.get_module_context
      end

    end
  end
end
