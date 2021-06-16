class Docin::Content::Import < Cms::Content
  default_scope { where(model: 'Docin::Import') }

  has_one :setting, foreign_key: :content_id, class_name: 'Docin::Content::Setting', dependent: :destroy
  delegate_attr_json_for :setting

  def gp_article_content
    setting.gp_article_content
  end

  def body_template
    setting.body_template.to_s
  end

  def summary_template
    setting.summary_template.to_s
  end

end
