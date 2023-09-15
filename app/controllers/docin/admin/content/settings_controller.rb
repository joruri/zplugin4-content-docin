class Docin::Admin::Content::SettingsController < Cms::Admin::Content::SettingsController
  private

  def additional_item_attributes
    [:template_values => {}]
  end
end
