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

require_relative "github_actions/colorizer"
require_relative "github_actions/container"
require_relative "github_actions/job"
require_relative "github_actions/job_runner"
require_relative "github_actions/step"
require_relative "github_actions/workflow"

# classes for running the Github Actions locally
module GithubActions
  # regexps for some special actions which need to be handled differently
  CHECKOUT_ACTION = /\Aactions\/checkout(|@.*)\z/.freeze
  COVERALLS_ACTION = /\Acoverallsapp\/github-action(|@.*)\z/.freeze
end
