module Yast::Rake::Config
  module Gem
    NAME    = 'yast-rake'
    RPMNAME = "rubygem-#{NAME}"
    SPEC    = "#{NAME}.gemspec"

    attr_reader :package

    def setup
      @package = rake.config.package
    end

    def path
      package.dir.join package.dir, name
    end

    def name
      "#{NAME}-#{package.version}.gem"
    end

    def rpm_name
      RPMNAME
    end

    def spec
      SPEC
    end
  end

  register Gem

end

