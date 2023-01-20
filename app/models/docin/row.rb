class Docin::Row < ApplicationModel
  attr_accessor :data
  attr_accessor :doc
  attr_accessor :category_titles

  NAME = 'ディレクトリ名'
  STATE = '状態'
  TITLE = 'タイトル'
  FEATURE_1 = '記事一覧表示'
  FEED_STATE = '記事フィード表示'
  DISPLAY_PUBLISHED_AT = '公開日（表示用）'
  DISPLAY_UPDATED_AT = '更新日（表示用）'
  TASK_PUBLISH_PROCESS_AT = '公開開始日時'
  TASK_CLOSE_PROCESS_AT = '公開終了日時'
  INQUIRY_STATE = '連絡先表示'
  EVENT_STATE = 'イベントカレンダー表示'
  EVENT_PERIOD = 'イベント期間'
  EVENT_NOTE = 'イベント備考'
  EVENT_CATEGORY = 'イベントカテゴリ'
  MARKER_STATE = 'マップ表示'
  MARKER_SORT_NO = 'マップ一覧順'
  MARKER_CATEGORY = 'マップカテゴリ'
  MAP_TITLE = 'マップ名'
  MAP_COORDINATE = '座標'
  MAP_ZOOM = '縮尺'
  MAP_MARKER = 'マーカー'
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

  def category_titles_from_category_type_title(category_type_title)
    return [] if data[category_type_title].blank?
    data[category_type_title].split(/,|、/).map(&:strip).reject(&:blank?)
  end

  def category_titles_text
    category_titles.join(', ')
  end

  def feature_1
    feature_1_option.last
  end

  def feature_1_text
    feature_1_option.first
  end

  def feed_state
    feed_state_option.last
  end

  def feed_state_text
    feed_state_option.first
  end

  def display_published_at
    return if data[DISPLAY_PUBLISHED_AT].blank?
    Time.parse(data[DISPLAY_PUBLISHED_AT]) rescue nil
  end

  def display_updated_at
    return if data[DISPLAY_UPDATED_AT].blank?
    Time.parse(data[DISPLAY_UPDATED_AT]) rescue nil
  end

  def keep_display_updated_at
    !display_updated_at.nil?
  end

  def task_publish_process_at
    return if data[TASK_PUBLISH_PROCESS_AT].blank?
    Time.parse(data[TASK_PUBLISH_PROCESS_AT]) rescue nil
  end

  def task_close_process_at
    return if data[TASK_CLOSE_PROCESS_AT].blank?
    Time.parse(data[TASK_CLOSE_PROCESS_AT]) rescue nil
  end

  def inquiry_state
    inquiry_state_option.last
  end

  def inquiry_state_text
    inquiry_state_option.first
  end

  def event_state
    event_state_option.last
  end

  def event_state_text
    event_state_option.first
  end

  def event_periods
    return [] if data[EVENT_PERIOD].blank?
    data[EVENT_PERIOD].split(/\r\n|\r|\n/).map(&:strip).select(&:present?).map do |period|
      texts = period.split('～', 2).select(&:present?)
      dates = texts.map { |text| Date.parse(text) rescue nil }.reject(&:blank?)
      dates << dates.first.dup if dates.size == 1
      dates
    end.reject(&:blank?)
  end

  def event_periods_text
    event_periods.map { |period| period.join('～') }.join("\n")
  end

  def event_note
    data[EVENT_NOTE]
  end

  def event_category_titles
    return [] if data[EVENT_CATEGORY].blank?
    data[EVENT_CATEGORY].split(/,|、/).map(&:strip).reject(&:blank?)
  end

  def event_category_titles_text
    event_category_titles.join(', ')
  end

  def map_exist?
    map_lat.present? && map_lng.present?
  end

  def marker_state
    marker_state_option.last
  end

  def marker_state_text
    marker_state_option.first
  end

  def marker_sort_no
    data[MARKER_SORT_NO]
  end

  def marker_category_titles
    return [] if data[MARKER_CATEGORY].blank?
    data[MARKER_CATEGORY].split(/,|、/).map(&:strip).reject(&:blank?)
  end

  def marker_category_titles_text
    marker_category_titles.join(', ')
  end

  def map_title
    data[MAP_TITLE]
  end

  def map_coordinate
    data[MAP_COORDINATE]
  end

  def map_lat
    map_coordinates.first
  end

  def map_lng
    map_coordinates.last
  end

  def map_zoom
    data[MAP_ZOOM]
  end

  def map_markers
    return [] if data[MAP_MARKER].blank?
    data[MAP_MARKER].split(/\r\n|\r|\n/).map(&:strip).select(&:present?).map do |marker|
      name, coordinate = marker.split(/\(|（/)
      name.strip!
      lat = lng = nil
      unless coordinate.blank?
        coordinate.gsub!(/\)|）/, '')
        lat, lng = coordinate.split(/,|、/).map { |l| l.strip!; l.blank? ? nil : l }
      end
      [name, lat, lng]
    end
  end

  def map_markers_text
    map_markers.map do |marker|
      "#{marker[0]}(#{marker[1]},#{marker[2]})"
    end.join("\n")
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
      doc.errors.add(:base, "#{NAME}を入力してください")
    end
    if doc.state_draft? && doc.state_was == 'public'
      doc.errors.add(:base, "#{STATE}は公開から下書きに変更できません")
    end
    if doc.state_prepared? && doc.state_was == 'public'
      doc.errors.add(:base, "#{STATE}は公開から公開日時待ちに変更できません")
    end
    if doc.state_closed? && doc.state_was == 'draft'
      doc.errors.add(:base, "#{STATE}は下書きから公開終了に変更できません")
    end
  end

  private

  def map_coordinates
    return [] if map_coordinate.blank?
    " #{map_coordinate} ".split(/,|、/).map(&:strip)
  end

  def state_option
    return [] unless %w(下書き 公開日時待ち 公開 公開終了).include?(data[STATE])
    GpArticle::Doc.state_options.assoc(data[STATE]).presence || []
  end

  def feature_1_option
    return [] if data[FEATURE_1].blank?
    GpArticle::Doc.feature_1_options.assoc(data[FEATURE_1]).presence || []
  end

  def feed_state_option
    return [] if data[FEED_STATE].blank?
    GpArticle::Doc.feed_state_options.assoc(data[FEED_STATE]).presence || []
  end

  def inquiry_state_option
    return [] if data[INQUIRY_STATE].blank?
    Cms::Inquiry.state_options.assoc(data[INQUIRY_STATE]).presence || []
  end

  def event_state_option
    return [] if data[EVENT_STATE].blank?
    GpArticle::Doc.event_state_options.assoc(data[EVENT_STATE]).presence || []
  end

  def marker_state_option
    return [] if data[MARKER_STATE].blank?
    GpArticle::Doc.marker_state_options.assoc(data[MARKER_STATE]).presence || []
  end
end
