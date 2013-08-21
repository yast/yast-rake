require 'pathname'
require 'yast/rake/version'
require 'yast/rake/config'
require 'yast/rake/command'
require 'yast/rake/tasks'

module Yast
  module Rake

    def rake
      self
    end

    # Remove the method main#rake if it exists.
    # You should require 'yast/rake' only if you need to work with ruby Rake, like in a Rakefile
    def self.extended(main)
      main.singleton_class.__send__(:remove_method, :rake) if self.respond_to?(:rake)
    end

  end
end

# Extend the main object with rake to to get rake object to main scope in Rakefile
self.extend Yast::Rake

# Add rake.config
rake.extend Yast::Rake::Config

# Add rake.command
rake.extend Yast::Rake::Command
#
# Load the default configuration
Yast::Rake::Config.load_custom_modules
Yast::Rake::Command.load_custom_modules

# Import the default built-in tasks
# Custom tasks will be loaded after the custom config modules are loaded
Yast::Rake::Tasks.import_default_tasks


# Import the custom tasks if there are any
# Inspected dirs: [ tasks/, rake/tasks/ ]
Yast::Rake::Tasks.import_custom_tasks(rake.config.root)
