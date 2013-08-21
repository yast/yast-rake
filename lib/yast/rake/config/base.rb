module Yast
  module Rake
    module Config
      module Base
        def root
          return @root if @root
          if defined?(::Rake)
            rake_file_path, pwd = ::Rake.application.find_rakefile_location
            rake_file_path.slice!(/(#{::Rake::Application::DEFAULT_RAKEFILES.join('|')})/)
            @root = Pathname.new(pwd).join(rake_file_path).expand_path
          else
            #FIXME This only works if the command responsible for loading the application
            #      code is loaded from the repo root.
            #      We need some discovery method that checks for some hints like:
            #      * Rakefile location (expect it to be in the repository root)
            #      * .git directory (the same as Rakefile)
            #      * VERSION and RPMNAME and MAINTAINER
            Pathname.new(Dir.pwd)
          end
        end
      end
    end
  end
end
