require 'yast/rake/config'
require 'yast/rake/command'

module Yast
  module Rake
    module Test
      include Config
      include Command
    end
  end
end

