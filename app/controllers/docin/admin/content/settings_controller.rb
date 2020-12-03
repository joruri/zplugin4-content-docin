class Docin::Admin::Content::SettingsController < Cms::Admin::Content::SettingsController
  def model
    Docin::Content::Setting
  end
end
