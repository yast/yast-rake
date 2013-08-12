require 'minitest/autorun'

ENV["Y2DIR"] = File.expand_path("../../src", __FILE__)

require 'yast'

# Use in case you want to test your custom rake commands, tasks, configs
# require 'yast/rake/test'


# This allows to run all test files with a single call
# `ruby test/test_helper.rb`
if __FILE__ == $0
  $LOAD_PATH.unshift('test')
  Dir.glob('./test/**/*_test.rb') { |f| require f }
end

# Use `require_relative "test_helper"` on top of your test files to be able to
# run them separately with command `ruby test/some_test.rb`
# Or use `rake test` to run the whole testsuite
