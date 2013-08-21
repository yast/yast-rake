namespace :gem do

  desc "Create a gem for yast-rake"
  task :build do
    rake.command.gem.build
  end

  desc "Create an rpm package from gem"
  task :rpm do
    #TODO
  end

  desc "Install the code from repository as a rubygem"
  task :install do
    rake.command.gem.install
  end
end
