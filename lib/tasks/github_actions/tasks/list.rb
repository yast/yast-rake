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
    # print the defined Github Actions jobs
    class List
      def run
        Workflow.read.each do |workflow|
          workflow.jobs.each do |job|
            # print rake commands so users can easily copy&paste into terminal
            puts "rake actions:run[#{job.name}]"
          end
        end
      end
    end
  end
end
