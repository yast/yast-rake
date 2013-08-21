module Yast
  module Rake
    module Tasks
      DEFAULT_TASKS_DIR = File.join(File.dirname(__FILE__), 'tasks')
      CUSTOM_TASKS_DIR_NAMES = [ 'tasks', 'rake/tasks' ]

      def self.import tasks_dir
        Dir.glob("#{tasks_dir}/**/*.rake").each do |rake_task|
          ::Rake.application.add_import(rake_task)
        end
      end

      def self.import_custom_tasks rake_root
        CUSTOM_TASKS_DIR_NAMES.each do |task_dir|
          import rake_root.join(task_dir)
        end
      end

      def self.import_default_tasks
        import DEFAULT_TASKS_DIR
      end

      # needed for the default.rake task to record tasks metadata
      # must be set before loading the tasks
      ::Rake::TaskManager.record_task_metadata = true

    end
  end
end
