class Docin::Row < ApplicationModel

  attr_accessor :data
  attr_accessor :doc

  NAME = 'ID'
  TITLE = 'タイトル'
  NO = '地図掲載順'
  LAT = '緯度'
  LNG = '経度'
  CATS = ['区分', '分野', 'ライフイベント', 'イベント情報']

  def state
    'public'
  end

  def no
    data[NO]
  end

  def name
    data[NAME]
  end

  def title
    data[TITLE]
  end

  def lat
    data[LAT]
  end

  def lng
    data[LNG]
  end

  def category_titles
    CATS.map { |k| data[k] }.select(&:present?)
  end

  def validate
    doc.validate

    if doc.name.blank?
      doc.errors.add(:base, 'IDを入力してください。')
    end
  end
end
