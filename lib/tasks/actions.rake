# frozen_string_literal: true

#--
# Yast rake
#
# Copyright (C) 2021 SUSE LLC
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

require_relative "github_actions/tasks"

# tasks related to GitHub Actions (https://docs.github.com/en/actions)
namespace :actions do
  desc "List the GitHub Action jobs"
  task :list do
    GithubActions::Tasks::List.new.run
  end

  desc "Display GitHub Action job details"
  task :details do
    GithubActions::Tasks::Details.new.run
  end

  desc "Run the specified GitHub Action job locally"
  task :run, [:job] do |_task, args|
    name = args[:job]
    abort "ERROR: Missing job name argument" if name.nil? || name.empty?

    GithubActions::Tasks::Run.new(name).run
  end

  desc "Run all supported GitHub Action jobs locally"
  task :"run:all" do
    GithubActions::Tasks::RunAll.new.run
  end
end
