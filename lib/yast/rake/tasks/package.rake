namespace :package do
  desc "Information about the package"
  task :info do
    #TODO create the rake.config.package.info
    puts rake.config.package.name
    puts rake.config.package.version
    puts rake.config.package.maintainer
  end

  desc "Create a new yast package skeleton"
  task :init do
    #TODO
    puts "Creating a new package skeleton"
  end

end

task :package => :"package:info"
