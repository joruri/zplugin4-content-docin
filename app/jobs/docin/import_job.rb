class Docin::ImportJob < Sys::ProcessJob
  queue_as :batch
  queue_with_priority 10
  process_name 'docin/docs/import'

  def perform(content, options = {})
    if options[:path]
      csv = NKF.nkf('-w', File.read(content.setting.import_path))
    else
      csv = options[:csv]
    end
    doc_ids = load_docs(content).state(:public).pluck(:id)

    rows = Docin::Parse::CsvInteractor.call(
      content: content,
      user: script.process.user,
      csv: csv
    ).results

    script.total! rows.size
    rows.each do |row|
      script.progress! row do
        doc_ids.reject!{|doc_id| doc_id == row&.doc&.id }
        update_doc(row)
      end
    end

    doc_ids.each_slice(500) do |partial_doc_ids|
      GpArticle::Doc.where(id: partial_doc_ids).update_all(state: 'closed')
      docs = GpArticle::Doc.where(id: partial_doc_ids)
      Cms::PublishersJob.perform_later(content.site, publications: docs.flat_map(&:publications))
    end
  end

  private

  def load_docs(content)
    content.gp_article_content.docs
  end

  def update_doc(row)
    row.doc.categorizations.each do |c|
      c.destroy if c.marked_for_destruction?
    end
    row.doc.maps.each do |map|
      map.markers.each do |marker|
        marker.destroy if marker.marked_for_destruction?
      end
      map.destroy if map.marked_for_destruction?
    end
    row.doc.files.each do |file|
      file.destroy if file.marked_for_destruction?
    end
    if row.doc.save && (row.doc.state_public? || row.doc.state_closed?)
      Docin::PublisherJob.perform_later(row.doc)
    end
  end
end
