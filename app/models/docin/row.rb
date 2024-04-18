class Docin::Row < ApplicationModel
  attr_accessor :data
  attr_accessor :content
  attr_accessor :doc
  attr_accessor :category_titles

  def initialize(attrs = {})
    super(attrs)
    @data[content.setting.file_name] = file_name
  end

  def state
    if content.status_dictionary.blank?
      data[content.setting.doc_state] || content.setting.default_state
    else
      content.status_dictionary[data[content.setting.doc_state]] || content.setting.default_state
    end
  end

  def state_text
    state_option.first || content.setting.default_state_text
  end

  def name
    data[content.setting.doc_name]
  end

  def title
    data[content.setting.title]
  end

  def category_titles_from_category_type_title(category_type_title)
    return [] if data[category_type_title].blank?
    data[category_type_title].split(/,|、/).map(&:strip).reject(&:blank?)
  end

  def category_titles_from_category_type_dictionary(title)
    cats = []
    dict = content.category_type_dictionary
    dict.each_key do |key|
      next if title != dict[key]
      cats.push(data[key])
    end
    cats
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
    return if data[content.setting.display_published_at].blank?
    Time.parse(data[content.setting.display_published_at]) rescue nil
  end

  def display_updated_at
    return if data[content.setting.display_updated_at].blank?
    Time.parse(data[content.setting.display_updated_at]) rescue nil
  end

  def keep_display_updated_at
    !display_updated_at.nil?
  end

  def task_publish_process_at
    return if data[content.setting.task_publish_process_at].blank?
    Time.parse(data[content.setting.task_publish_process_at]) rescue nil
  end

  def task_close_process_at
    return if data[content.setting.task_close_process_at].blank?
    Time.parse(data[content.setting.task_close_process_at]) rescue nil
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
    return [] if data[content.setting.event_period].blank?
    data[content.setting.event_period].split(/\r\n|\r|\n/).map(&:strip).select(&:present?).map do |period|
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
    data[content.setting.event_note]
  end

  def event_category_titles
    return [] if data[content.setting.event_category].blank?
    data[content.setting.event_category].split(/,|、/).map(&:strip).reject(&:blank?)
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
    data[content.setting.marker_sort_no]
  end

  def marker_category_titles
    return [] if data[content.setting.marker_category].blank?
    data[content.setting.marker_category].split(/,|、/).map(&:strip).reject(&:blank?)
  end

  def marker_category_titles_text
    marker_category_titles.join(', ')
  end

  def map_title
    data[content.setting.map_title]
  end

  def map_coordinate
    data[content.setting.map_coordinate]
  end

  def map_lat
    map_coordinates.first
  end

  def map_lng
    map_coordinates.last
  end

  def map_zoom
    data[content.setting.map_zoom]
  end

  def map_markers
    return [] if data[content.setting.map_marker].blank?
    data[content.setting.map_marker].split(/\r\n|\r|\n/).map(&:strip).select(&:present?).map do |marker|
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
    data[content.setting.file_path]
  end

  def file_name
    File.basename(file_path) if file_path
  end

  def file_title
    data[content.setting.file_title]
  end

  def file_alt_text
    data[content.setting.file_alt_text]
  end

  def file_image_resize
    data[content.setting.file_image_resize]
  end

  def validate
    doc.validate

    if doc.name.blank?
      doc.errors.add(:base, "#{NAME}を入力してください")
    end
    if doc.state_closed? && doc.state_was == 'draft'
      doc.errors.add(:base, "#{STATE}は下書きから公開終了に変更できません")
    end
  end

  def doc_uri
    return nil if content.setting.uri_base.blank?
    uri = content.setting.uri_base.gsub(/@data\[\"(.+?)\"]/){|s| data[$1] }
    uri
  end

  private

  def map_coordinates
    return [] if map_coordinate.blank?
    " #{map_coordinate} ".split(/,|、/).map(&:strip)
  end

  def state_option
    GpArticle::Doc.state_options.find{ |o| o.last == state } || []
  end

  def feature_1_option
    return [] if data[content.setting.feature_1].blank?
    GpArticle::Doc.feature_1_options.assoc(data[content.setting.feature_1]).presence || []
  end

  def feed_state_option
    return [] if data[content.setting.feed_state].blank?
    GpArticle::Doc.feed_state_options.assoc(data[content.setting.feed_state]).presence || []
  end

  def inquiry_state_option
    return [] if data[content.setting.inquiry_state].blank?
    Cms::Inquiry.state_options.assoc(data[content.setting.inquiry_state]).presence || []
  end

  def event_state_option
    return [] if data[content.setting.event_state].blank?
    GpArticle::Doc.event_state_options.assoc(data[content.setting.event_state]).presence || []
  end

  def marker_state_option
    return [] if data[content.setting.marker_state].blank?
    GpArticle::Doc.marker_state_options.assoc(data[content.setting.marker_state]).presence || []
  end
end
