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

require_relative "../github_actions"

module GithubActions
  module Tasks
    # print the defined Github Actions jobs with details
    class Details
      include Colorizer

      def run
        Workflow.read.each_with_index do |workflow, index|
          workflow.jobs.each do |job|
            # empty line separator if multiple jobs are found
            puts if index > 0

            # print the job details
            success(job.name)
            puts "  run: \"rake actions:run[#{job.name}]\""
            puts "  container: #{job.container}"
            puts "  steps:"
            job.steps.each do |step|
              puts "    #{step.name}"
              puts "      #{step.run}" if step.run
              puts "      #{step.uses}" if step.uses
            end
          end
        end
      end
    end
  end
end
