class Docin::Row < ApplicationModel
  attr_accessor :data
  attr_accessor :doc
  attr_accessor :category_titles

  NAME = 'ディレクトリ名'
  TITLE = 'タイトル'
  MARKER_SORT_NO = 'マップ一覧順'
  MAP_COORDINATE = '座標'

  def state
    'public'
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

  def validate
    doc.validate

    if doc.name.blank?
      doc.errors.add(:base, "#{NAME}を入力してください。")
    end
  end
end
