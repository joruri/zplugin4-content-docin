class Zplugin::Content::Docin::Log < ApplicationRecord
  belongs_to :content, class_name: 'Docin::Content::Import'

  enum_ish :parse_state, [:start, :parse, :link, :end]

  def set_status(opts)
    self.update_columns(opts)
  end

end
