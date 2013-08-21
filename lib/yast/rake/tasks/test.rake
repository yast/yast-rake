desc "Run the whole test suite"
task :test do
  test_dirs = {
    :test => rake.config.root.join('test'),
    :spec => rake.config.root.join('spec')
  }

  test_dirs.each do |test_type, test_dir|
    if Dir.exists?(test_dir)
      test_helper_file = Dir.glob("#{test_dir}/#{test_type}_helper.rb").first
    else
      next
    end

    puts "Found helper file #{test_helper_file}" if rake.verbose

    unless test_helper_file
      abort \
        "File #{test_dir}/#{test_type}_helper.rb not found.\n" +
        "Please create one and set up your tests there.\n"    +
        "This task expects you to put `require 'minitest/autorun` into the helper file."
    end

    puts "Loading helper file #{test_helper_file}" if rake.verbose
    require test_helper_file

    puts "Extending load path by #{test_dir}" if rake.verbose
    $LOAD_PATH.unshift test_dir

    puts "Loading all test files from #{test_dir}" if rake.verbose

    # Test files shouldn't be expected to load in any specific order.
    # When still in doubt look here:
    # http://www.ruby-doc.org/stdlib-2.0/libdoc/minitest/rdoc/MiniTest/Unit/TestCase.html#method-c-i_suck_and_my_tests_are_order_dependent-21
    Dir.glob("#{test_dir}/**/*_#{test_type}.rb") { |test_file| require test_file }
  end
end

task :spec => [:test]
