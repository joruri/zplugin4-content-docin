class Docin::Content::Setting < Cms::ContentSetting
  default_scope { joins(:content) }

  attr_json :gp_article_content_id, :integer
  attr_json :body_template, :string
  attr_json :summary_template, :string
  attr_json :default_state, :string, enum: [:draft, :public], default: :draft
  attr_json :template_values, ActiveModel::Type::Value.new, default: {}
  attr_json :import_path, :string
  attr_json :import_user_id, :integer
  attr_json :column_replace, :text
  attr_json :category_relation, :text
  attr_json :category_relation_type, :integer, enum: [0, 1], default: 1
  attr_json :attachement_column, :string
  attr_json :attachement_directory, :string

  attr_json :doc_name, :string, default: "ディレクトリ名"
  attr_json :doc_state, :string, default: "ステータス"
  attr_json :title, :string, default: "タイトル"
  attr_json :feature_1, :string, default: "記事一覧表示"
  attr_json :feed_state, :string, default: "記事フィード表示"
  attr_json :display_published_at, :string, default: "公開日（表示用）"
  attr_json :display_updated_at, :string, default: "更新日（表示用）"
  attr_json :task_publish_process_at, :string, default: "公開開始日時"
  attr_json :task_close_process_at, :string, default: "公開終了日時"
  attr_json :inquiry_state, :string, default: "連絡先表示"
  attr_json :event_state, :string, default: "イベントカレンダー表示"
  attr_json :event_period, :string, default: "イベント期間"
  attr_json :event_note, :string, default: "イベント備考"
  attr_json :event_category, :string, default: "イベントカテゴリ"
  attr_json :marker_state, :string, default: "地図表示"
  attr_json :marker_sort_no, :string, default: "地図表示順"
  attr_json :marker_category, :string, default: "マップカテゴリ"
  attr_json :map_title, :string, default: "マップ名"
  attr_json :map_coordinate, :string, default: "座標"
  attr_json :map_zoom, :string, default: "縮尺"
  attr_json :map_marker, :string, default: "マーカー"
  attr_json :file_path, :string, default: "添付ファイル"
  attr_json :file_name, :string, default: "添付ファイル名"
  attr_json :file_title, :string, default: "表示ファイル名"
  attr_json :file_alt_text, :string, default: "代替テキスト"
  attr_json :file_image_resize, :string, default: "画像リサイズ"


  attr_json_belongs_to :gp_article_content, class_name: 'GpArticle::Content::Doc'
  attr_json_belongs_to :import_user, class_name: 'Sys::User'

  validates_with GpTemplate::TemplateValuesValidator

  def gp_article_content_id_text
    gp_article_content&.name
  end

  def import_user_id_text
    import_user&.name
  end

  def template
    gp_article_content&.default_template
  end

  def files
    []
  end

  private

  class << self
    def gp_article_content_id_options(options = {})
      GpArticle::Content::Doc.in_site(options[:site]).map { |c| [c.name, c.id] }
    end

    def import_user_id_options(options = {})
      Sys::User.in_site(options[:site]).to_options
    end
  end
end
