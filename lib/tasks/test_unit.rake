namespace :test do
  desc "Runs unit tests."
  task "unit" do
    files = Dir["**/test/**/*_{spec,test}.rb"].sort
    sh "rspec --color --format doc '#{files.join("' '")}'" unless files.empty?
  end
end
