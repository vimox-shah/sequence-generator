module SequenceGenerator
  class Engine < ::Rails::Engine
    isolate_namespace SequenceGenerator

    initializer "sequence_generator", before: :load_config_initializers do |app|
      Rails.application.routes.append do
        mount SequenceGenerator::Engine, at: "/sequence_generator"
      end
      SequenceGenerator.load_files.each { |file|
        require_relative File.join("../..", file)
      }
    end
  end
end
