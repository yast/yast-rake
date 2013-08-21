require 'minitest/autorun'
#require 'minitest/spec'

lib_dir = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require 'yast/rake/test'

# this allows to run all test files with a single call
# `ruby spec/spec_helper.rb`
if __FILE__ == $0
  $LOAD_PATH.unshift('spec')
  Dir.glob('./spec/**/*_spec.rb') { |f| require f }
end

# Use `require_relative "spec_helper"` on top of your spec files to be able to
# run them separately with command `ruby spec/some_spec.rb`
# Use `rake spec` to run the whole testsuite.

