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
namespace :version do
  def version
    Yast::Tasks.spec_version
  end

  desc "Increase the last part of version in package/*.spec files"
  task :bump do
    version_parts = version.split(".")
    version_parts[-1] = (version_parts.last.to_i + 1).to_s
    new_version = version_parts.join(".")

    puts "Updating version to #{new_version}"

    # update all present *.spec files
    Dir.glob("package/*.spec").each do |spec_file|
      spec = File.read(spec_file)
      spec.gsub!(/^\s*Version:.*$/, "Version:        #{new_version}")

      File.write(spec_file, spec)
    end
  end

  desc "Bump package version and create a simple class for acessing the version from sources"
  task wbump: :bump do
    puts "Generating helper class"

    Dir.glob("**/lib/*") do |path|
      next if !File.directory?(path)

      module_name = File.basename(path).downcase
      target_file = "#{module_name}_version.rb"
      target_path = "#{path}/#{target_file}"

      puts "Writing helper class to: #{target_path}"

      class_definition = <<-eof
module Yast
  class #{module_name.capitalize}Version
    VERSION = "#{version}".freeze
  end
end
      eof

      File.write(target_path, class_definition)
    end
  end
end
