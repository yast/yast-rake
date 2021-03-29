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

module GithubActions
  # Github Actions job
  # @see https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions
  class Job
    attr_reader :name, :steps, :runs_on, :container, :workflow

    # @param name [String] name of the job
    # @param data [Hash] data from the workflow YAML file
    # @param workflow [GithubActions::Workflow] the parent workflow
    def initialize(name, data, workflow)
      @name = name
      @runs_on = data["runs-on"]
      @container = data["container"]
      @workflow = workflow

      @steps = data["steps"].map do |step|
        Step.new(self, step)
      end
    end

    # check if the defined steps can be used locally
    # @return [Array<String>] the list of unsupported steps, returns empty
    #  list if all actions are supported
    def unsupported_steps
      steps.each_with_object([]) do |step, array|
        array << step.name unless step.supported?
      end
    end
  end
end
