module Yast::Rake::Config
  module Package
    PREFIX          = 'yast-'

    VERSION_FILE    = 'VERSION'
    RPMNAME_FILE    = 'RPMNAME'
    MAINTAINER_FILE = 'MAINTAINER'
    README_FILE     = 'README'

    PACKAGE_DIR     = 'package'
    LICENSE_DIR     = 'license'
    CONFIG_DIR      = 'config'
    RAKE_DIR        = 'rake'
    TEST_DIR        = 'test'
    COVERAGE_DIR    = 'coverage'
    DOC_DIR         = 'doc'

    SRC_DIR     = 'src'
    DESKTOP_DIR = "#{SRC_DIR}/desktop"
    MODULES_DIR = "#{SRC_DIR}/modules"
    CLIENTS_DIR = "#{SRC_DIR}/clients"
    INCLUDE_DIR = "#{SRC_DIR}/include"

    class Files

      def initialize rake
        @rake = rake
      end

      def all
        Dir["#{root_dir}/**/*"]
      end

      def desktop
        Dir["#{root_dir.join DESKTOP_DIR}/*.desktop"]
      end

      def clients
        Dir["#{root_dir.join CLIENTS_DIR}"]
      end

      def changes
        Dir["#{root_dir.join PACKAGE_DIR}/.changes'"]
      end

      def config
        Dir["#{root_dir.join CONFIG_DIR}/**/*"]
      end

      def modules
        Dir["#{root_dir.join MODULES_DIR}/**/*"]
      end

      def test
        Dir["#{root_dir.join TEST_DIR}/**/*"]
      end

      def src
        Dir["#{root_dir.join SRC_DIR}/**/*"]
      end

      def package
        Dir["#{root_dir.join PACKAGE_DIR}/**/*"]
      end

      def size
        all.size
      end

      def inspect
        "[ #{(public_methods(false) - [:inspect]).sort.join ', '} ]"
      end

      private

      def root_dir
        @rake.config.root
      end
    end

    class Dirs
      def initialize rake
        @rake = rake
      end

      def src
        root_dir.join SRC_DIR
      end

      def inspect
        "[ #{(public_methods(false) - [:inspect]).sort.join ', '} ]"
      end

      private

      def root_dir
        @rake.config.root
      end
    end


    attr_reader   :version, :name, :maintainer, :files, :dirs
    attr_accessor :domain

    def setup
      @dirs      = Dirs.new(rake)
      @domain    = get_domain_from_rpmname
      @mainainer = read_maintainer_file
      @name      = read_rpmname_file
      @version   = read_version_file
      @files     = Files.new(rake)
    end

    def dir
      @dir ||= rake.config.root.join 'package'
    end

    private

    def read_file file
      if File.exists?(file)
        read_content(file)
      else
        errors << "Mandatory file '#{file}' not found."
        nil
      end
    end

    def read_content file
      content = File.read(file).strip
      errors.push("File '#{file}' must not be empty.") if content.size.zero?
      content
    end

    def get_domain_from_rpmname
      name.to_s.split(PREFIX).last
    end

    def read_version_file
      read_file(rake.config.root.join VERSION_FILE)
    end

    def read_rpmname_file
      read_file(rake.config.root.join RPMNAME_FILE)
    end

    def read_maintainer_file
      read_file(rake.config.root.join MAINTAINER_FILE)
    end

  end
end
