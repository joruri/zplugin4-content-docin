class Docin::Content::Import < Cms::Content
  default_scope { where(model: 'Docin::Import') }

  #has_many :settings, -> { order(:sort_no) },
  #                    foreign_key: :content_id, class_name: 'Docin::Content::Setting', dependent: :destroy
  has_one :setting, foreign_key: :content_id, class_name: 'Docin::Content::Setting', dependent: :destroy
                      delegate_attr_json_for :setting

  def gp_article_content
    #GpArticle::Content::Doc.find_by(id: setting.gp_article_content_id)
    setting.gp_article_content
  end

  def body_template
    setting.body_template.to_s
  end

  def summary_template
    setting.summary_template.to_s
  end

  

end
