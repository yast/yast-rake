require "packaging"

# yast integration testing takes too long and require osc:build so it create
# circle, so replace test dependency with test:unit
task = Rake::Task["package"]
prerequisites = task.prerequisites
prerequisites.delete("test")
prerequisites.push("test:unit")
# ensure we have proper version in spec
prerequisites.push("version:update_spec")

task.enhance(prerequisites)

Packaging.configuration do |conf|
  conf.obs_project = "YaST:Head"
  conf.obs_sr_project = "openSUSE:Factory"
  conf.package_name = File.read("RPMNAME").strip if File.exists?("RPMNAME")
end

# load own tasks
task_path = File.expand_path("../../tasks", __FILE__)
Dir["#{task_path}/*.rake"].each do |f|
  load f
end
