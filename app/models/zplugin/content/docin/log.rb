class Zplugin::Content::Docin::Log < ApplicationRecord
  belongs_to :content, class_name: 'Docin::Content::Import'

  def set_status(opts)
    self.update_columns(opts)
  end

end
