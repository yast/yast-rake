module Yast::Rake::Command
  module Gem
    include FileUtils

    def install
      build
      puts "Installing #{rake.config.gem.name} from #{rake.config.gem.path} ..."
      sh "gem install #{rake.config.gem.path}"
    end

    def build
      package = rake.config.package
      gem     = rake.config.gem

      sh "gem build #{gem.spec}"
      puts "Gem file is available in #{package.dir.join gem.name}"
      rm gem.name
    end

    def rpm
      #TODO
    end
  end

  register Gem
end
