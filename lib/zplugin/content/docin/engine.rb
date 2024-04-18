module Zplugin
  module Content
    module Docin
      class Engine < ::Rails::Engine
        engine_name 'zplugin_content_docin'
        isolate_namespace Zplugin::Content::Docin
        config.eager_load_paths += %W(#{config.root}/lib/autoloads)

        config.after_initialize do |app|
          app.config.assets.precompile += %w(docin/admin.js docin/admin.css)
        end

        config.to_prepare do
          Dir.glob(Zplugin::Content::Docin::Engine.root.join("app/overrides/**/*_override.rb")).each do |c|
            require_dependency(c)
          end
        end

        class << self
          def version
            VERSION
          end

          def install
          end

          def uninstall
            ::Docin::Content::Import.destroy_all
          end
        end
      end
    end
  end
end
