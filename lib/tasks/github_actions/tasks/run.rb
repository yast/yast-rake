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
    # run the requested Github Actions job locally
    class Run
      include Colorizer

      # the requested job name
      attr_reader :name

      # constructor
      # @param name [String] name of the job to run
      def initialize(name)
        @name = name
      end

      # run the GitHub Action locally
      def run
        runner = GithubActions::JobRunner.new(find_job, ENV["DOCKER_IMAGE"])
        abort unless runner.run
      end

    private

      # read the job definition from YAML file
      def find_job
        job = nil
        Workflow.read.each do |workflow|
          # Note: in theory the same job name might be used in different files,
          # but in YaST we use single YAML files and we can avoid duplicates,
          # simply use the first found and avoid unnecessary complexity
          job = workflow.jobs.find { |j| j.name == name }
        end

        check_job(job)

        job
      end

      # check if the job is valid and can be run locally,
      # it aborts when the job cannot be used
      def check_job(job)
        if job.nil?
          error("ERROR: Job \"#{name}\" not found")
          abort
        end

        unsupported = job.unsupported_steps
        if !unsupported.empty?
          error("ERROR: These steps are not supported: #{unsupported.inspect}")
          abort
        end

        return if job.container && !job.container.empty?

        error("ERROR: Docker image name is missing in the job definition")
        abort
      end
    end
  end
end
