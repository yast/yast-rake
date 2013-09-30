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
    File.read("VERSION").strip
  end

  desc "Increase last part of version of file and propagate change with update_spec"
  task :bump do
    version_parts = version.split(".")
    version_parts[-1] = (version_parts.last.to_i + 1).to_s
    File.write("VERSION", version_parts.join(".") + "\n")
    Rake::Task["version:update_spec"].execute
  end

  desc "Propagate version from VERSION file to rpm spec file"
  task :update_spec do
    sh "sed -i 's/\\(^Version:[[:space:]]*\\)[0-9.]\\+/\\1#{version}/' package/*.spec"
  end
end
