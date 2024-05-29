class Docin::Export::DocsInteractor < ApplicationInteractor
  context_in :items, required: true
  context_out :result

  def call
    @result = CSV.generate(force_quotes: true) do |csv|
      csv << header
      @items.each do |item|
        csv << to_csv(item)
      end
    end
  end

  private

  def header
    # 基本情報
    data = ['記事タイトル','ステータス','記事ID','旧URL','新URL']
    data
  end

  def to_csv(item)
    data = []

    # 基本情報
    data << item.title
    data << item&.docable&.state_text
    data << item.doc_name
    data << item.uri_path
    data << item.doc_public_uri
    data
  end

  def localize_datetime(value)
    I18n.l(value) if value
  end
end
