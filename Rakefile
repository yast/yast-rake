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

require_relative "lib/yast/rake"

Yast::Tasks.submit_to :sle12sp3

# remove tarball implementation and create gem for this gemfile
Rake::Task[:tarball].clear
# build the gem package
desc "Build gem package, save RPM sources to package subdirectory"
task :tarball do
  version = File.read("VERSION").chomp
  Dir["package/*.tar.bz2"].each do |f|
    rm f
  end

  Dir["package/*.gem"].each do |g|
    rm g
  end

  sh "gem build yast-rake.gemspec"
  mv "yast-rake-#{version}.gem", "package"
end

# remove install implementation and install via gem
Rake::Task[:install].clear
desc "Install yast-rake gem package"
task install: :tarball do
  sh "sudo gem install --local package/yast-rake*.gem"
end

# this gem uses VERSION file, replace the standard yast implementation
Rake::Task[:'version:bump'].clear

namespace :version do
  task :bump do
    # update VERSION
    version_parts = File.read("VERSION").strip.split(".")
    version_parts[-1] = (version_parts.last.to_i + 1).to_s
    new_version = version_parts.join(".")

    puts "Updating to #{new_version}"
    File.write("VERSION", new_version + "\n")

    # update *.spec file
    spec_file = "package/rubygem-yast-rake.spec"
    spec = File.read(spec_file)
    spec.gsub!(/^\s*Version:.*$/, "Version:        #{new_version}")
    File.write(spec_file, spec)
  end
end

Yast::Tasks.configuration do |conf|
  conf.package_name = "rubygem-yast-rake"
end
# vim: ft=ruby
