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
    # run all supported Github Action jobs locally
    class RunAll
      include Colorizer

      # run all jobs one by one, continue even if a job fails,
      # print the summary in the end
      def run
        # collect failed jobs
        failed_jobs = []
        workflows = Workflow.read
        # custom Docker image requested?
        image = custom_image(workflows)

        workflows.each do |workflow|
          workflow.jobs.each do |job|
            # skip unsupported jobs
            next unless valid_job?(job)

            runner = JobRunner.new(job, image)
            failed_jobs << job.name if !runner.run
          end
        end

        print_result(failed_jobs)
      end

    private

      # check if a custom image can be used for all jobs,
      # if more than one Docker image is used than it's unlikely that
      # a same custom image will work for all jobs, rather abort in that case
      # to avoid some strange errors when using incorrect image
      # @param workflows [GithubActions::Workflow] all defined workflows
      # @return [String,nil] the custom Docker image name or `nil` if not specified
      def custom_image(workflows)
        return nil unless ENV["DOCKER_IMAGE"]

        images = workflows.each_with_object([]) do |workflow, arr|
          workflow.jobs.each do |job|
            arr << job.container if job.container && !arr.include?(job.container)
          end
        end

        if images.size > 1
          error("More than one Docker image is used in the workflows,")
          error("DOCKER_IMAGE option cannot be used.")
          puts "Use DOCKER_IMAGE option for each job separately."
          abort
        end

        ENV["DOCKER_IMAGE"]
      end

      # print the final result
      # @param failed_jobs [Array<String>] list of failed jobs
      def print_result(failed_jobs)
        if failed_jobs.empty?
          success("Overall result: SUCCESS")
        else
          error("Failed jobs: #{failed_jobs.inspect}")
          error("Overall result: FAILURE!")
          abort
        end
      end

      # check if the job is valid and can be run locally,
      # if the job cannot be used it prints a warning
      # @return [Boolean] `true` if the job is valid, `false` otherwise
      def valid_job?(job)
        unsupported = job.unsupported_steps
        if !unsupported.empty?
          warning("WARNING: Skipping job \"#{job.name}\", found " \
                  "unsupported steps: #{unsupported.inspect}")
          return false
        end

        if job.container.nil? || job.container.empty?
          warning("WARNING: Skipping job \"#{job.name}\", " \
                  "the Docker container in not specified")
          return false
        end

        true
      end
    end
  end
end
