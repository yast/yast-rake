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
  # Runs GitHub Actions job in a container locally
  class JobRunner
    include Colorizer

    attr_reader :job, :image

    # constructor
    # @param job [GithubActions::Job] the job to run
    # @param image [String,nil] override the Docker image to use,
    #   if `nil` it by default uses the image specified in the job
    def initialize(job, image = nil)
      @job = job
      @image = image
    end

    # run the job in a container
    # @return [Boolean] `true` if all steps were successfully executed,
    #  `false` otherwise
    def run
      stage("Running \"#{job.name}\" job from file #{job.workflow.file}")
      start_container

      result = true
      job.steps.each do |step|
        result &= run_step(step)
      end

      print_result(result)
      container.stop
      result
    end

  private

    # GithubActions::Container
    attr_reader :container

    # pull the Docker image and start the container
    def start_container
      @container = find_container
      container.pull
      container.start
    end

    # Get the container configuration
    # @return [Container] container which should run the job
    def find_container
      # prefer the custom image if requested
      image_name = if image
        image
      elsif job.container.is_a?(String)
        job.container
      elsif job.container.is_a?(Hash)
        options = job.container["options"]
        job.container["image"]
      else
        abort "Unsupported container definition: #{job.container.inspect}"
      end

      Container.new(image_name, options.to_s)
    end

    # run a job step
    # @param step [GithubActions::Step] the step to run
    # @return [Boolean] `true` if the step succeeded, `false` otherwise
    def run_step(step)
      info("Step \"#{step.name}\"")

      # run "uses" step if present
      run_uses_step(step.uses) if step.uses

      # run "run" step if present
      return true unless step.run

      container.run(step.run)
    end

    # print the job result
    # @param success [Boolean] status of the job
    def print_result(success)
      if success
        success("Job result: SUCCESS")
      else
        error("Job result: FAILURE!")
      end
    end

    # workarounds for some special Javascript actions which are otherwise
    # not supported in general
    # @param uses [String] name of the "uses" action
    def run_uses_step(uses)
      case uses
      when CHECKOUT_ACTION
        # emulate the Git checkout action, just copy the current checkout
        # into the current directory in the running container
        container.copy_current_dir
      when COVERALLS_ACTION
        # skip the coveralls action, do not send the code coverage report
        # when running locally
        info("Skipping the Coveralls step")
      else
        # this should actually never happen, we already checked for
        # the unsupported steps before starting the job
        raise "Unsupported action \"#{uses}\""
      end
    end
  end
end
