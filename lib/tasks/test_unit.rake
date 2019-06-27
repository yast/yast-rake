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
#++

# defines $CHILD_STATUS
require "English"

def parallel_rspec_installed?
  system("which parallel_rspec &> /dev/null")
end

def parallel_tests_wanted?
  (File.exist?(".rspec_parallel") && ENV["PARALLEL_TESTS"] != "0") ||
    ENV["PARALLEL_TESTS"] == "1"
end

def run_parallel_tests(files)
  # pass custom parameters to parallel_rspec if needed,
  # e.g. the number of CPUs to use
  sh("parallel_rspec --verbose #{ENV["PARALLEL_TESTS_OPTIONS"]} '#{files}'")

  # use coveralls for on-line code coverage reporting at Travis CI, it needs
  # to be called only once, after *all* parallel tests have been finished
  if ENV["COVERAGE"] && ENV["TRAVIS"] && File.exist?(".coveralls.yml")
    require "coveralls/rake/task"
    Coveralls::RakeTask.new
    Rake::Task["coveralls:push"].invoke
  end

  nil
end

def run_sequential_tests(files)
  sh("rspec --color --format doc '#{files}'")
  # with standard RSpec the code coverage is usually configured in the
  # test helper and is already sent at this point, no special handling
  # is required
end

namespace :test do
  desc "Runs unit tests."
  task "unit" do
    files = Dir["**/test/**/*_{spec,test}.rb"].join("' '")
    next if files.empty?

    # use parallel_tests if wanted and available
    if parallel_tests_wanted? && parallel_rspec_installed?
      run_parallel_tests(files)
    else
      if parallel_tests_wanted?
        warn "WARNING: parallel tests enabled, but 'parallel_rspec' is" \
        " not installed, falling back to the standard 'rspec' runner."
      end
      run_sequential_tests(files)
    end
  end
end
