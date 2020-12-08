module Zplugin
  module Content
    module Docin
      class Engine < ::Rails::Engine
        engine_name 'zplugin_content_docin'
        isolate_namespace Zplugin::Content::Docin

        config.after_initialize do |app|
          app.config.assets.precompile += %w(sample/admin.js sample/public.js)
        end

        class << self
          def version
            VERSION
          end
          
          def install
          end

          def uninstall
          end
        end
      end
    end
  end
end
