module Yast::Rake::Command
  module Gem
    include FileUtils

    def install
      build
      puts "Installing #{rake.config.gem.name} from #{rake.config.gem.path} ..."
      system "gem install #{rake.config.gem.path}"
    end

    def build
      package = rake.config.package
      gem     = rake.config.gem

      system "gem build #{gem.spec}"
      puts "Copying the gem file to package/ directory..."
      cp gem.name, package.dir.join(gem.name)
      rm gem.name
    end

    def rpm
      #TODO
    end
  end

  register Gem
end
