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

require "yaml"

module GithubActions
  # Github Actions workflow
  # @see https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions
  class Workflow
    attr_reader :file, :name, :on, :jobs

    # load all defined workflows from all YAML files
    # @return [Array<GithubActions::Workflow>]
    def self.read
      Dir[".github/workflows/*.{yml,yaml}"].map do |file|
        new(file)
      end
    end

    # load the workflow from an YAML file
    # @param file [String] path to the YAML file
    def initialize(file)
      @file = file
      yml = YAML.load_file(file)
      @name = yml["name"]
      # "on" is autoconverted to Boolean "true"!
      # see https://medium.com/@lefloh/lessons-learned-about-yaml-and-norway-13ba26df680
      @on = yml[true]

      @jobs = yml["jobs"].map do |name, job|
        Job.new(name, job, self)
      end
    end
  end
end
