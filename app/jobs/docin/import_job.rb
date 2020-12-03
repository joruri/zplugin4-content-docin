class Docin::ImportJob < ApplicationJob
  def perform(content, user, csv)
    @dest_content = content.gp_article_content

    rows = Docin::ParseService.new(content, user).parse(csv)
    prev_names = @dest_content.docs.group(:name).pluck(:name)
    next_names = rows.map(&:name)

    update_docs(rows)
    close_docs(prev_names - next_names)

    # Cms::RebuildJob.perform_later(content.site, target_content_ids: [content.id])
  end

  private

  def update_docs(rows)
    rows.each do |row|
      row.doc.categorizations.each do |c|
        c.destroy if c.marked_for_destruction?
      end
      row.doc.save
    end
  end

  def close_docs(names)
    @dest_content.docs.where(name: names).order(:id).each do |doc|
      doc.close
    end
  end
end
