class Docin::Row < ApplicationModel
  attr_accessor :data
  attr_accessor :doc

  NAME = 'ディレクトリ名'
  TITLE = 'タイトル'
  MARKER_SORT_NO = 'マップ一覧順'
  MAP_COORDINATE = '座標'
  CATS = ['区分', '分野', 'ライフイベント', 'イベント情報']

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

  def category_titles
    CATS.map { |k| data[k] }.select(&:present?)
  end

  def validate
    doc.validate

    if doc.name.blank?
      doc.errors.add(:base, "#{NAME}を入力してください。")
    end
  end
end
