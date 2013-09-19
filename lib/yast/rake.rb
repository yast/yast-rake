require "packaging"

Packaging::Configuration.run do |conf|
  conf.obs_project = "Yast:Head"
  conf.obs_sr_project = "openSUSE:Factory"
  conf.package_name = File.read("RPMNAME").strip if File.exists?("RPMNAME")
end
