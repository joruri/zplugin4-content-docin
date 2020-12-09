class Docin::Content::SettingField < Cms::Content::SettingField
  menu :gp_article_relation do
    add_item :gp_article_content_id, :select
    add_item :body_template, :text_area
    add_item :summary_template, :text_area
  end
end
