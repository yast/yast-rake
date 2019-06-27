# frozen_string_literal: true

#--
# Yast rake
#
# Copyright (C) 2018 SUSE LLC
#   This library is free software; you can redistribute it and/or modify
# it only under the terms of version 2.1 of the GNU Lesser General Public
# License as published by the Free Software Foundation.
#
#   This library is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
# details.
#
#++

def rubocop_bin
  return @rubocop_bin if @rubocop_bin
  return @rubocop_bin = ENV["RUBOCOP_BIN"] if ENV["RUBOCOP_BIN"]

  version = system("grep 'rubocop-0.71.0' .rubocop.yml") ? "0.71.0" : "0.41.2"
  binary = `/usr/sbin/update-alternatives --list rubocop | grep '#{version}'`.strip
  if !system("which #{binary}")
    raise "cannot find proper version of rubocop binary in " \
      "'/usr/sbin/update-alternatives --list rubocop'." \
      "If rubocop is installed via gem, define its binary name via env variable RUBOCOP_BIN."
  end
  @rubocop_bin = binary
end

# run Rubocop in parallel
# @param params [String] optional Rubocop parameters
def run_rubocop(params = "")
  # how it works:
  # 1) get the list of inspected files by Rubocop
  # 2) shuffle it randomly (better would be evenly distribute them according to
  #    the analysis complexity but that is hard to evaluate and even simply
  #    distributing by file size turned out to be ineffective and slower than
  #    a simple random shuffling)
  # 3) pass that as input for xargs
  #    a) use -P with number of processors to run the commands in parallel
  #    b) use -n to set the maximum number of files per process, this number
  #       is computed to equally distribute the files across the workers
  sh "#{rubocop_bin} -L | sort -R | xargs -P`nproc` -n$(expr `#{rubocop_bin} -L | wc -l` / " \
    "`nproc` + 1) #{rubocop_bin} #{params}"
end

namespace :check do
  desc "Run Rubocop in parallel"
  task :rubocop, [:options] do |_task, args|
    args.with_defaults = { options: "" }
    run_rubocop(args[:options])
  end

  desc "Run Rubocop in parallel in the auto correct mode"
  task :"rubocop:auto_correct", [:options] do |_task, args|
    args.with_defaults = { options: "" }
    run_rubocop("-a #{args[:options]}")
  end
end
