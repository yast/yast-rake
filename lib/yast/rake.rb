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
require "packaging"
require_relative "tasks"

# yast integration testing takes too long and require osc:build so it create
# circle, so replace test dependency with test:unit
task = Rake::Task["package"]
prerequisites = task.prerequisites
prerequisites.delete("test")

task.enhance(prerequisites)

Yast::Tasks.configuration do |conf|
  conf.obs_project = "YaST:Head"
  conf.obs_sr_project = "openSUSE:Factory"
  conf.package_name = File.read("RPMNAME").strip if File.exist?("RPMNAME")
  conf.version = Yast::Tasks.spec_version if !Dir.glob("package/*.spec").empty?
  conf.skip_license_check << /spell.dict$/ # skip license check for spelling dictionaries
end

# load own tasks
task_path = File.expand_path("../../tasks", __FILE__)
Dir["#{task_path}/*.rake"].each do |f|
  load f
end

# optionally load the tasks from yast-rake-ci if it is installed
begin
  require "yast/rake_ci"
rescue LoadError
  puts "INFO: Gem yast-rake-ci not installed, extra tasks not loaded" if verbose == true
end
