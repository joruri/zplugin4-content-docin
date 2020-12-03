class Docin::Content::Setting < Cms::ContentSetting
  
  default_scope { joins(:content) }

  attr_json :gp_article_content_id, :integer
  attr_json :body_template, :string
  attr_json :summary_template, :string

  attr_json_belongs_to :gp_article_content, class_name: 'GpArticle::Content::Doc'

  def gp_article_content_id_text
    gp_article_content&.name
  end

private

class << self

  def gp_article_content_id_options(options = {})
    GpArticle::Content::Doc.in_site(options[:site]).map { |c| [c.name, c.id] }
  end
end

end
