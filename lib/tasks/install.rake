#--
# Yast rake
#
# Copyright (C) 2014 Novell, Inc.
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

require "packaging/configuration"

module Packaging
  # extend configuration with install locations
  class Configuration
    attr_writer :install_locations

    DESTDIR = ENV["DESTDIR"] || "/"
    YAST_DIR = DESTDIR + "/usr/share/YaST2/"
    YAST_LIB_DIR = DESTDIR + "/usr/lib/YaST2/"
    YAST_ICON_BASE_DIR = DESTDIR + "/usr/share/YaST2/theme/current/icons"
    YAST_DESKTOP_DIR = DESTDIR + "/usr/share/applications/YaST2/"
    AUTOYAST_RNC_DIR = YAST_DIR + "schema/autoyast/rnc/"

    # specific directory that contain dynamic part of package name
    def install_doc_dir
      DESTDIR + "/usr/share/doc/packages/#{package_name}/"
    end

    # Gets installation locations. Hash contain glob as keys and target
    # directory as values. Each found file/directory from glob is passed
    # to FileUtils.cp_r as source and value as destination
    def install_locations
      @install_locations ||= {
        "**/src/clients"                    => YAST_DIR,
        "**/src/modules"                    => YAST_DIR,
        "**/src/include"                    => YAST_DIR,
        "**/src/lib"                        => YAST_DIR,
        "**/src/scrconf"                    => YAST_DIR,
        "**/src/data"                       => YAST_DIR,
        "**/src/servers_non_y2"             => YAST_LIB_DIR,
        "**/src/bin"                        => YAST_LIB_DIR,
        "**/src/autoyast[_-]rnc/*"          => AUTOYAST_RNC_DIR,
        "**/src/fillup/*"                   => fillup_dir,
        "**/src/desktop/*.desktop"          => YAST_DESKTOP_DIR,
        "{README*,COPYING,CONTRIBUTING.md}" => install_doc_dir,
        "**/icons/*"                        => YAST_ICON_BASE_DIR
      }
    end

    # Possible fillup templates directories
    FILLUP_DIRS = ["/usr/share/fillup-templates", "/var/adm/fillup-templates"].freeze

    # @return [String] fillup-templates directory
    def fillup_dir
      found = FILLUP_DIRS.find { |d| Dir.exist?(d) }
      reldir = found || FILLUP_DIRS.first
      DESTDIR + reldir
    end
  end
end

desc "Install to system"
task :install do
  config = ::Packaging::Configuration.instance
  config.install_locations.each_pair do |glob, install_to|
    FileUtils.mkdir_p(install_to, verbose: true) unless File.directory?(install_to)
    Dir[glob].each do |source|
      begin
        # do not use FileUtils.cp_r as it have different behavior if target
        # exists and we copy a symlink
        sh "cp -r '#{source}' '#{install_to}'"
      rescue => e
        raise "Cannot install file #{source} to #{install_to}: #{e.message}"
      end
    end
  end
end
