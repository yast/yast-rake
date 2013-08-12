require 'minitest/autorun'
require 'minitest/spec'

ENV["Y2DIR"] = File.expand_path("../../src", __FILE__)

require 'yast'

# Use in case you want to test your custom rake commands, tasks, configs
# require 'yast/rake/test'

# This allows to run all test files with a single call
# `ruby spec/spec_helper.rb`
if __FILE__ == $0
  $LOAD_PATH.unshift('spec')
  Dir.glob('./spec/**/*_spec.rb') { |f| require f }
end

# Use `require_relative "spec_helper"` on top of your spec files to be able to
# run them separately with command `ruby spec/some_spec.rb` .
# Or use `rake spec` to run the whole testsuite.
