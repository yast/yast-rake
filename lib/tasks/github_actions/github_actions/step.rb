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
  # Github Actions step
  # @see https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions
  class Step
    attr_reader :job, :name, :uses, :run, :env

    # constructor
    # @param job [GithubActions::Job] the parent job
    # @param step [Hash] the step definition from the YAML file
    def initialize(job, step)
      @job = job
      @name = step["name"]
      @uses = step["uses"]
      @run = step["run"]
      @env = step["env"]
    end

    # we can run the step if it is just a plain command (not a Javascript or
    # Docker container action) and the environment variables do not contain any
    # expansions (usually used for Github secrets)
    # @return [Boolean] `true` if the step is supported, `false` otherwise
    def supported?
      known_uses? && !expansion?
    end

  private

    # Javascript or Docker actions are not supported
    # @return [Boolean] `true` if there is a workaround defined for the step
    def known_uses?
      uses.nil? || uses.match?(CHECKOUT_ACTION) || uses.match?(COVERALLS_ACTION)
    end

    # we cannot expand the Github secrets
    # @return [Boolean] `true` if an expansion is found, `false` otherwise
    def expansion?
      env&.any? { |_k, v| v.to_s.include?("${{") }
    end
  end
end
