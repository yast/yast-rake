namespace :test do
  desc "Runs unit tests."
  task "unit" do
    files = Dir["**/test/**/*_{spec,test}.rb"]
    # sort the files to have reproducible runs
    files.sort!
    sh "rspec --color --format doc '#{files.join("' '")}'" unless files.empty?
  end
end
