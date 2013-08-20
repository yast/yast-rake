# Yast::Rake

Rake extension for yast with tasks, configs and commands

## Installation

This code is not available as a rpm package nor a ruby gem yet, below
you find more details on how to install it from this git repo.

1. `git clone git@github.com:yast/yast-rake.git`
2. `cd yast-rake`
3. `rake gem:install` or `sudo rake gem:install`
  * use sudo if you are using system ruby installation;

## Usage

1. `cd some/yast/git/repository`
2. `echo "require 'yast/rake'" > Rakefile`
4. `rake`

`rake` is the default task which lists all available tasks:

  >  rake check          # Run all check tasks  
  >  rake check:package  # Check package code completness  
  >  rake check:syntax   # Check syntax of *.{rb,rake} files  
  >  rake console        # Start irb session with yast/rake loaded  
  >  rake gen:spec       # Create 'spec/' and 'spec/spec_helper.rb'  
  >  rake gen:test       # Create 'test/' and 'test/test_helper.rb'  
  >  rake install        # Install the yast code on the current system  
  >  rake package:info   # Meta information about the yast package  
  >  rake package:init   # Create a new yast package skeleton  
  >  rake test           # Run all tests  


## Features

### Config

  * use for configuration
  * not dependent on Rake
  * available with `rake.config` in tasks and commands (see below)
  * API for defining config modules:
    * ruby module name becomes `rake.config.downcased_module_name`
    * module instance methods available from `rake.config.downcased_module_name.*methods`
    * method `setup` for initializing the configuration
    * look at config examples below to get a clearer picture
  * put your custom config modules into `rake/configs` directory to get them loaded

### Command

  * use for rake tasks implementation to better testing and managing
  * not dependent on Rake
  * available with `rake.command`
  * put your custom commands into `rake/commands` directory to get them loaded

### Tasks

  * predefined common tasks for all yast modules (not yet completed, pull requests welcome)
  * defined with rake syntax
  * implementation via commands (see examples below)
  * put yor custom tasks into `rake/tasks/` directory to get them loaded 

### Test it

  If you are going to write test cases for some yast module where there were none before,
  use the tasks for generating the directory with helper file:
  * `rake gen:test` creates test/ directory and test/test_helper.rb file from a template
  * `rake gen:spec` creates spec/ directory and spec/spec_helper.rb file from a template


## Examples

### Config example

  in `rake/configs/package.rb`

  ```ruby
module Yast::Rake::Config
  module Package
    VERSION_FILE_NAME = 'VERSION'
    RPM_FILE_NAME = 'RPMNAME'

    attr_reader :version
    attr_reader :name

    def setup
      @version_file = rake.config.root.join(VERSION_FILE_NAME)
      @rpmname_file = rake.config.root.join(RPM_FILE_NAME)
      fail "Version file not found" unless File.exists?(@version_file)
      fail "Rpm-name file not found" unless File.exists?(@rpmname_file)
      @version = File.read(@version_file).strip
      @name    = File.read(@rpmname_file).strip
      errors << "File #{VERSION_FILE_NAME} must not be empty" if @version.size.zero?
      errors << "File #{RPM_FILE_NAME} must not be empty"     if @version.size.zero?
    end
  end

  register Package

end
  ```

  Config modules get loaded automatically from the path `rake/configs/` after the
  default configs has been loaded.  

  Defining your custom config in namespace `Yast::Rake::Config` has the advantages of:  
    * avoiding namespace collision  
    * in place registering right after the config module definition  
    * keeping Rakefile clean from custom code.  


### Command example

  in `rake/commands/package.rb`

  ```ruby
module Yast::Rake::Command
  module Package
    include FileUtils # no need to require 'fileutils' as they are already loaded

    def install
      sh "rpm -i #{rake.config.package.name}-#{rake.config.package.version}.rpm"
      puts "Package has been install successfully"
    end
  end

  register Package

end
  ```

### Task example

  in `rake/tasks/package.rake`

  ```ruby
namespace :package do
  desc "Install the package"
  task :install do
    rake.command.package.install
  end
end
  ```

  Running `rake package:install` will execute the task/command.

### Test it!

  You should test your tasks, i.e. commands appropriately and make them a part of the 
  yast module testsuite. Getting the `rake` object is easy:

  ```ruby
require 'yast/rake/test'

attr_reader :rake

before do
  @rake = Object.new.extend(Yast::Rake::Test)
end

# we expect the custom code is located at rake/configs and rake/commands dirs
describe "Your custom code"
  rake.config.must_respond_to :package
  rake.command.package.must_respond_to :install
end
  ```

### Rake console

  You can see the default configs and commands by running `rake console` which
  starts an IRB session and loads `rake` object into the main scope. `rake.config` 
  and `rake.command` return list of registered modules.

  It offers a hook for code you want to run after the irb session starts, 
  like importing some yast modules or setup some personal greetings :). The 
  hook expects a proc and it's empty by default, feel free to override it if needed.

  ```ruby
module Yast::Rake::Config
  module Console
    def proc
      Proc.new do
        ENV["Y2DIR"] = File.expand_path("../../src", __FILE__)
        require 'yast'
        ::Yast.import 'Sysconfig'
      end
    end
  end

  register Console
end
  ```

## Todo

  * Add comments for Yard
  * Add more tests
  * Add some kind of logging based on rake cli options --verbose and --trace
  * Fix spec file
  * Add task for building/installing any yast module
  * Identify more useful tasks for obs, git etc.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin new-feature`)
5. Create new Pull Request on https://github.com/yast/yast-rake
