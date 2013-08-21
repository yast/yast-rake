desc "Start irb session with yast/rake loaded"
task :console do
  rake.command.console.start
end

#TODO add rake.config.console.reload! method or rake.reload!
