# frozen_string_literal: true

#--
# Copyright (C) 2009, 2010 Novell, Inc.
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

Gem::Specification.new do |spec|
  # gem name and description
  spec.name = "yast-rake"
  spec.version = File.read(File.expand_path("VERSION", __dir__)).chomp
  spec.license = "LGPL v2.1"

  # author
  spec.author  = "Josef Reidinger"
  spec.email = "jreidinger@suse.cz"
  spec.homepage = "https://github.com/yast/yast-rake"
  spec.required_ruby_version = ">= 2.5.0"

  spec.summary = "Rake tasks providing basic work-flow for Yast development"
  spec.description = <<~DESCRIPTION
    Rake tasks that support work-flow of Yast developer. It allows packaging repo,
    send it to build service, create submit request to target repo or run client
    from git repo.
  DESCRIPTION

  # gem content
  spec.files = Dir["lib/**/*.rb", "lib/tasks/spell.yml", "lib/tasks/*.rake",
    "data/*", "COPYING", "VERSION"]

  # define LOAD_PATH
  spec.require_path = "lib"

  # dependencies
  spec.add_dependency("packaging_rake_tasks", ">= 1.1.4")
  spec.add_dependency("rake")
  spec.metadata["rubygems_mfa_required"] = "true"
end
