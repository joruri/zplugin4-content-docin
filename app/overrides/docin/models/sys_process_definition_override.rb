module Docin::Models::SysProcessDefinitionOverride
  extend ActiveSupport::Concern
  included do
    add_item 'docin/docs/import', '記事取り込み', sort_no: 6000
  end
end

Sys::Process::Definition.include Docin::Models::SysProcessDefinitionOverride
