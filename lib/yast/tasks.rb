#--
# Yast rake
#
# Copyright (C) 2009-2013 Novell, Inc.
#   This library is free software; you can redistribute it and/or modify
# it only under the terms of version 2.1 of the GNU Lesser General Public
# License as published by the Free Software Foundation.
#
#   This library is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
# details.
#
#   You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
#++

require "yaml"

# create wrapper to Packaging Configuration
module Yast
  # Yast::Task module contains helper methods
  module Tasks
    # Targets definition
    TARGETS_FILE = File.expand_path("../../../data/targets.yml", __FILE__)

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

    def self.submit_to(target, file = TARGETS_FILE)
      targets = YAML.load_file(file)
      config = targets[target]
      if config.nil?
        raise "No configuration found for #{target}. Known values: #{targets.keys.join(", ")}"
      end
      Yast::Tasks.configuration do |conf|
        config.each do |meth, val|
          conf.public_send("#{meth}=", val)
        end
      end
    end
  end
end
