require_relative 'spec_helper'

class TestRake
  def initialize
    self.extend Yast::Rake::Config
  end
end


describe Yast::Rake::Config do
  attr_reader :rake

  before do
    @rake = TestRake.new
  end

  it "allows access to default configuration modules" do
    rake.config.must_respond_to :root
    rake.config.must_respond_to :yast
    rake.config.must_respond_to :package
    rake.config.must_respond_to :console
  end

  it "allows extending the config by ruby module" do
    module MyCoolConfig
      PATH = 'crazy>path>>>'
      def path
        PATH
      end
    end

    Yast::Rake::Config.register MyCoolConfig
    rake.config.must_respond_to :my_cool_config
    rake.config.my_cool_config.must_respond_to :path
    rake.config.my_cool_config.path.must_equal MyCoolConfig::PATH
  end

  it "allows extending the config without the module namespace" do
    module YourBaseConfig
      VERSION = '30.3.0'
      def version
        VERSION
      end
    end

    Yast::Rake::Config.register YourBaseConfig, false
    rake.config.must_respond_to :version
    rake.config.wont_respond_to :your_base_config
    rake.config.version.must_equal YourBaseConfig::VERSION
  end

  it "should be able to namespace the module and register it there" do
    module Yast::Rake::Config
      module AnythingNeeded
        def hex
          0x0045
        end
      end
      register AnythingNeeded
    end

    rake.config.must_respond_to :anything_needed
    rake.config.anything_needed.must_respond_to :hex
    rake.config.anything_needed.hex.must_equal 0x0045
  end

end


