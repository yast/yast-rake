# create wrapper to Packaging Configuration
module Yast
  # Yast::Task module contains helper methods
  module Tasks
    def self.configuration(&block)
      ::Packaging.configuration(&block)
    end

    # read the version from spec file
    def self.spec_version
      # use the first *.spec file found, assume all spec files
      # contain the same version
      File.readlines(Dir.glob("package/*.spec").first)
        .grep(/^\s*Version:\s*/).first.sub("Version:", "").strip
    end
  end
end

