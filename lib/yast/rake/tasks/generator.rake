namespace :gen do
  NOTE_ABOUT_YAST_RUBY = \
    "\nYou need to run `zypper install yast2-ruby-bindings` " +
    "unless you already have that rpm installed."

  templates_dir = Pathname.new(File.dirname(__FILE__)).join('templates')

  desc "Create 'test/' directory and 'test/test_helper.rb' file"
  task :test do
    test_dir = rake.config.root.join('test')
    helper_template = templates_dir.join('test_helper.rb')
    unless File.exists?(test_dir)
      mkdir test_dir
      cp helper_template, test_dir
      puts NOTE_ABOUT_YAST_RUBY
    end
  end

  desc "Create 'spec/' directory and 'spec/spec_helper.rb' file"
  task :spec do
    spec_dir = rake.config.root.join('spec')
    helper_template = templates_dir.join('spec_helper.rb')
    unless File.exists?(spec_dir)
      mkdir spec_dir
      cp helper_template, spec_dir
      puts NOTE_ABOUT_YAST_RUBY
    end
  end
end

task :g => :gen
