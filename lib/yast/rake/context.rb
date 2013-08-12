module Yast
  module Rake
    module Context

      CustomHash = Class.new(Hash) do
        def inspect
          "[ #{keys.join(', ')} ]"
        end
      end

      def self.extended(mod)
        mod.module_name = parse_module_name(mod)
        mod.context[mod.module_name] = CustomHash.new
        mod.context.define_singleton_method(mod.module_name) do
          mod.context[mod.module_name]
        end
      end

      def self.context
        @context ||= ContextManager.new
      end

      attr_accessor :module_name

      def context_name=(mod)
        @context_name ||= parse_module_name(mod)
      end

      def register mod, keep_module_name=true
        context_name = parse_module_name(mod)
        if keep_module_name
          context.remove(module_name, context_name)
          context.add(module_name, mod, context_name)
        else
          context.remove_base(module_name, mod)
          context.add_base(module_name, mod)
        end
      end

      def context
        Context.context
      end

      def get_module_context
        context[module_name]
      end

      def parse_module_name mod
        mod.to_s                     \
        .split("::").last            \
        .split(/(?=[A-Z])/)          \
        .map(&:downcase).join('_')   \
        .to_sym
      end

      module_function :parse_module_name

      class ContextManager
        attr_reader   :rake
        attr_reader   :context

        def initialize
          @context = CustomHash.new
          @rake = context
        end

        def [](context_name)
          context[context_name]
        end

        def []=(context_name, value)
          context[context_name] = value
        end

        def add module_name, mod, context_name
          context[module_name][context_name] = ContextProxy.new(context_name, self).extend(mod)
          context[module_name].define_singleton_method(context_name) { self[context_name] }
        end

        def remove module_name, context_name
          if context[module_name].respond_to?(context_name)
            context[module_name].singleton_class.__send__(:undef_method, context_name)
            context[module_name].delete(context_name)
          end
        end

        def add_base module_name, mod
          context[module_name].extend(mod)
          mod.public_instance_methods.each do |context_name|
            context[module_name][context_name] = nil
          end
        end

        def remove_base module_name, mod
          mod.public_instance_methods.each do |context_method|
            if context[module_name].respond_to?(context_method)
              #FIXME this blocks extending of base modules in method add_base
              #context[module_name].singleton_class.send(:undef_method, context_method)
              context[module_name].delete(context_method)
            end
          end
        end

        def get_downcased_module_name mod
          mod.to_s
          .split("::").last
          .split(/(?=[A-Z])/)
          .map(&:downcase).join('_').to_sym
        end

        def verbose
          defined?(::Rake) ? ::Rake.verbose == true : false
        end

        def trace
          defined?(::Rake) ? ::Rake.application.options.trace == true : false
        end


        class ContextProxy

          SETUP_METHOD = :setup

          attr_reader :rake, :context_name, :errors

          def initialize context_name, rake
            @rake   = rake
            @errors = []
            @context_name = context_name
            @context_methods = []
            @errors_reported = false
          end

          def extend mod
            make_setup_method_private(mod)
            mod.public_instance_methods(false).each do |method_name|
              @context_methods.push(method_name) unless @context_methods.include?(method_name)
            end
            super           # keep the Object.extend functionality
            run_setup       # call the setup method from config module
            report_errors   # if setup collected errors, show them now
            self            # return the extended context
          end

          def inspect
            "[ #{@context_methods.sort.join(', ')} ]"
          end

          def report_errors force_report=false
            if force_report || !@errors_reported
              errors.each do |err_message|
                STDERR.puts("#{context_name.capitalize}: #{err_message}")
                set_exit_code_to_one unless @exit_code
              end
            end
            @errors_reported = true
          end

          def check
            report_errors
          end

          def check!
            report_errors
            Kernel.abort "Found #{errors.size} #{errors.one? ? 'error' : 'errors'}."
          end

          private

          def make_setup_method_private mod
            if mod.public_instance_methods.include?(SETUP_METHOD)
              mod.__send__(:private, SETUP_METHOD)
            end
          end

          def run_setup
            __send__(SETUP_METHOD) if respond_to?(SETUP_METHOD, true)
          end

          def set_exit_code_to_one
            puts "Setting exit code to 1" if rake.verbose
            @exit_code = 1
            Kernel.at_exit { exit @exit_code }
          end
        end

      end

    end
  end
end
