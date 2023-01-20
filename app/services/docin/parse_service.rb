class Docin::ParseService < ApplicationService
  def initialize(content, user)
    @content = content
    @user = user

    @builder = Docin::BuildService.new(@content, @user)
  end

  def parse(csv)
    require 'csv'
    rows = CSV.parse(csv, headers: true, skip_blanks: true)
              .reject { |data| data.to_h.values.all?(&:nil?) }
              .map { |data| Docin::Row.new(data: data) }

    doc_map = load_doc_map(rows)
    rows.each do |row|
      row.doc = @builder.build(row, doc: replace(doc_map[row.name], row))
    end

    rows
  end

  private

  def load_doc_map(rows)
    @content.gp_article_content.docs
            .where(name: rows.map(&:name))
            .order(:id)
            .preload(:content, :creator, :editor, :files, :inquiries,
                     :event_categories, :marker_categories, :maps => :markers)
            .index_by(&:name)
  end

  def replace(doc, row)
    if doc.blank? || !(doc.state_public? && %w(draft prepared).include?(row.state))
      doc
    else
      dup = doc.duplication(state: row.state)
      dup.prev_edition = doc
      dup
    end
  end
end
