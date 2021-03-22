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

require_relative "github_actions/github_actions"

# Run a client in Docker container
class ContainerRunner
  include GithubActions::Colorizer

  # start a container, copy the sources there and run "rake run"
  # @param client [String,nil] the client name, nil or empty string = find
  #   the client automatically
  def run(client)
    image = find_image
    container = GithubActions::Container.new(image)
    container.pull
    container.start
    container.copy_current_dir

    cmd = client ? "rake run[#{client}]" : "rake run"
    container.run(cmd)

    container.stop
  end

private

  # find the Docker image to use in the container
  # @return [String] the image name
  def find_image
    # explicitly requested image
    image = ENV["DOCKER_IMAGE"]
    return image if image && !image.empty?

    # scan the Docker images used in the GitHub Actions
    images = workflow_images
    return images.first if images.size == 1

    if images.empty?
      error("No Docker image was found in the GitHub Actions")
      puts "Use DOCKER_IMAGE=<name> option for specifying the image name"
      abort
    end

    # multiple images found
    error("Found multiple Docker images in the GitHub Actions:")
    error(images.inspect)
    puts "Use DOCKER_IMAGE=<name> option for specifying the image name"
    abort
  end

  # extract the Docker images from the GitHub Actions,
  # the duplicates are removed
  # @return [Array<String>] image names
  def workflow_images
    GithubActions::Workflow.read.each_with_object([]) do |workflow, images|
      workflow.jobs.each do |job|
        container = job.container
        images << container if container && !images.include?(container)
      end
    end
  end
end
