class Docin::Row < ApplicationModel
  attr_accessor :data
  attr_accessor :doc
  attr_accessor :category_titles

  NAME = 'ディレクトリ名'
  STATE = '状態'
  TITLE = 'タイトル'
  MARKER_SORT_NO = 'マップ一覧順'
  MAP_COORDINATE = '座標'
  FILE_PATH = '添付ファイル'
  FILE_NAME = '添付ファイル名'
  FILE_TITLE = '表示ファイル名'
  FILE_ALT_TEXT = '代替テキスト'
  FILE_IMAGE_RESIZE = '画像リサイズ'

  def initialize(attrs = {})
    super(attrs)
    @data[FILE_NAME] = file_name
  end

  def state
    state_option.last
  end

  def state_text
    state_option.first
  end

  def name
    data[NAME]
  end

  def title
    data[TITLE]
  end

  def marker_sort_no
    data[MARKER_SORT_NO]
  end

  def map_coordinate
    data[MAP_COORDINATE]
  end

  def map_lat
    data[MAP_COORDINATE].split(/,|、/).first
  end

  def map_lng
    data[MAP_COORDINATE].split(/,|、/).last
  end

  def category_title(category_type_title)
    data[category_type_title]
  end

  def file_path
    data[FILE_PATH]
  end

  def file_name
    File.basename(file_path) if file_path
  end

  def file_title
    data[FILE_TITLE]
  end

  def file_alt_text
    data[FILE_ALT_TEXT]
  end

  def file_image_resize
    data[FILE_IMAGE_RESIZE]
  end

  def validate
    doc.validate

    if doc.name.blank?
      doc.errors.add(:base, "#{NAME}を入力してください。")
    end
    if doc.state_draft? && doc.state_was == 'public'
      doc.errors.add(:base, "#{STATE}は公開から下書きに変更できません。")
    end
    if doc.state_closed? && doc.state_was == 'draft'
      doc.errors.add(:base, "#{STATE}は下書きから公開終了に変更できません。")
    end
  end

  private

  def state_option
    return [] unless %w(下書き 公開 公開終了).include?(data[STATE])
    GpArticle::Doc.state_options.assoc(data[STATE]).presence || []
  end
end
