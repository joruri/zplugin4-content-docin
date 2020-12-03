module Zplugin
  module Content
    module Docin
      class Engine < ::Rails::Engine
        engine_name 'zplugin_content_docin'

        config.after_initialize do |app|
          app.config.x.engines << self
        end

        class << self
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
