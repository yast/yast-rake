namespace :test do
  desc "Runs unit tests."
  task "unit" do
    Dir["**/test/**/*_{spec,test}.rb"].each do |f|
      sh "rspec --color --format doc '#{f}'"
    end
  end
end
