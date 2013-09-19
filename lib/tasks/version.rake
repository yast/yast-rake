namespace :version do
  def version
    File.read("VERSION").strip
  end

  desc "Increase last part of version of file and propagate change with update_spec"
  task :bump do
    version_parts = version.split(".")
    version_parts[-1] = (version_parts.last.to_i + 1).to_s
    File.write("VERSION", version_parts.join("."))
    Rake::Task["version:update_spec"].execute
  end

  desc "Propagate version from VERSION file to rpm spec file"
  task :update_spec do
    sh "sed -i 's/\\(^Version:[[:space:]]*\\)[0-9.]\\+/\\1#{version}/' package/*.spec"
  end
end
