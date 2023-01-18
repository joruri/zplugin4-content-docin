class Docin::ImportJob < ApplicationJob
  def perform(content, user, csv)
    rows = Docin::ParseService.new(content, user).parse(csv)
    update_docs(rows)
  end

  private

  def update_docs(rows)
    rows.each do |row|
      row.doc.categorizations.each do |c|
        c.destroy if c.marked_for_destruction?
      end
      row.doc.files.each do |file|
        file.destroy if file.marked_for_destruction?
      end
      if row.doc.save
        Cms::PublicateInteractor.call(item: row.doc)
      end
    end
  end
end
