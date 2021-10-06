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

require "English"
require "shellwords"

module GithubActions
  # Manage a Docker container
  class Container
    include Colorizer

    attr_reader :image, :options, :container

    # the default timeout in seconds, maximum time for the running container,
    # after the time runs out the container is automatically stopped and removed
    # unless `KEEP_CONTAINER` option is set
    TIMEOUT = 3600

    # the default environment variables in the container
    ENV_VARIABLES = {
      # this is a CI environment
      "CI"             => "true",
      # skip the modified check in the "rake osc:build" task
      "CHECK_MODIFIED" => "0"
    }.freeze

    # constructor
    # @param image [String] name of the Docker image to use
    # @param options [String, nil] extra docker options
    def initialize(image, options = nil)
      @image = image
      @options = options
    end

    # pull the Docker image, ensure that the latest version is used
    def pull
      stage("Pulling the #{image} image...")
      # if the latest image is already present it does nothing
      system("docker pull #{image.shellescape}")
    end

    # start the container, runs "docker create" and "docker start"
    def start
      stage("Starting the container...")

      # define the initial command for the container to start
      if keep_container?
        # running "tail -f /dev/null" does nothing and gets stuck forever,
        # this ensures the container keeps running and we can execute
        # the other commands there via "docker exec"
        run = "tail"
        args = "-f /dev/null"
      else
        # the "sleep" command ensures the container shuts down automatically after
        # the timeout (to abort frozen jobs or avoid hanging containers after a crash)
        run = "sleep"
        args = TIMEOUT
      end

      cmd = "docker create #{env_options(ENV_VARIABLES)} --rm --entrypoint " \
        "#{run} #{options} #{ENV["DOCKER_OPTIONS"]} #{image.shellescape} #{args}"

      # contains the container ID
      @container = `#{cmd}`.chomp
      system("docker start #{container.shellescape} > /dev/null")
    end

    # stop and remove the container from the system, runs "docker rm"
    def stop
      if keep_container?
        print_container_usage
      else
        stage("Stopping the container...")
        system("docker rm --force #{container.shellescape} > /dev/null")
      end
    end

    # run a command in the container, runs "docker exec"
    # the command is executed in a shell, so shell metacharacters like "&&"
    # can be used to join several commands
    # @param cmd [String] the command to run, it is passed to a shell to it might
    #   contain multiple commands or shell meta characters
    # @param env [Hash] optional environment variables (with mapping "name" => "value")
    # @return [Boolean] `true` if the command succeeded (exit status 0),
    #  `false` otherwise
    def run(cmd, env = {})
      stage("Running command: #{cmd}")
      system("docker exec -it #{env_options(env)} #{container.shellescape} " \
        "sh -c #{cmd.shellescape}")
      $CHILD_STATUS.success?
    end

    # get the current working directory in the container
    # @return [String] the path
    def cwd
      `docker exec #{container.shellescape} pwd`.chomp
    end

    # copy the files from host into the container
    # @param from [String] the source path, if it is a directory all content
    #   is copied (including subdirectories)
    # @param to [String] the target location in the container
    def copy_files(from, to)
      stage("Copying #{from} to #{to} in the container...")

      if File.directory?(from)
        # Dir.children is similar to Dir.entries but it omits the "." and ".." values
        Dir.children(from).each do |f|
          system("docker cp #{f.shellescape} #{container.shellescape}:#{to.shellescape}")
        end
      else
        system("docker cp #{from.shellescape} #{container.shellescape}:#{to.shellescape}")
      end
    end

    # copy the current directory to the current directory in the container
    def copy_current_dir
      copy_files(Dir.pwd, cwd)
    end

  private

    # should we keep the container at the end or remove it?
    def keep_container?
      ENV["KEEP_CONTAINER"] == "1" || ENV["KEEP_CONTAINER"] == "true"
    end

    # when we keep the container running print some hints how to use it
    def print_container_usage
      warning("The Docker container is still running!")
      puts "Use this command to connect to it:"
      # docker accepts shortened IDs, make the commands shorter
      info("  docker exec -it #{container[0..16]} bash")
      puts "To stop and remove the container run:"
      info("  docker rm -f #{container[0..16]}")
    end

    # build the docker environment command line options
    # @param mapping [Hash] environment variables
    # @return [String] the built Docker options
    def env_options(mapping)
      mapping.map do |name, value|
        "-e #{name.shellescape}=#{value.shellescape}"
      end.join(" ")
    end
  end
end
