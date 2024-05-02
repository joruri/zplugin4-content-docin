class Docin::ImportJob < Sys::ProcessJob
  queue_as :batch
  queue_with_priority 10
  process_name 'docin/docs/import'

  def perform(content, options = {})
    log = content.log || content.create_log
    last_updated_at = log.parse_start_at
    default_values = { parse_state: "start", parse_start_at: Time.now, parse_end_at: nil, last_updated_at: last_updated_at,
    register_total: 0, register_success: 0, register_failure: 0 }
    log.set_status(default_values)
    if options[:path]
      csv = NKF.nkf('-w', File.read(content.setting.import_path))
    else
      csv = options[:csv]
    end
    doc_ids = load_docs(content).state(:public).pluck(:id)

    log.set_status({parse_state: "parse"})
    rows = Docin::Parse::CsvInteractor.call(
      content: content,
      user: script.process.user,
      csv: csv
    ).results
    register_total = 0
    register_success = 0
    register_failure = 0
    script.total! rows.size
    rows.each do |row|
      register_total += 1
      script.progress! row do
        doc_ids.reject!{|doc_id| doc_id == row&.doc&.id }
        if update_doc(row)
          register_success += 1
        else
          register_failure += 1
        end
      end
      log.set_status(register_total: register_total, register_success: register_success, register_failure: register_failure)

      if rdoc = row&.doc
        cdoc = Zplugin::Content::Docin::Doc.find_or_initialize_by(uri_path: row.doc_uri)
        cdoc.docable = rdoc
        cdoc.content = rdoc.content
        cdoc.body    = rdoc.body
        cdoc.docable = rdoc
        cdoc.doc_name = rdoc.name
        cdoc.doc_public_uri = rdoc.public_uri
        cdoc.published_at = rdoc.published_at
        cdoc.title = rdoc.title
        cdoc.page_updated_at = rdoc.updated_at
        cdoc.page_published_at = rdoc.published_at
        cdoc.updated_at = Time.now
        cdoc.save
      end
    end
    if content.auto_closure?
      doc_ids.each_slice(500) do |partial_doc_ids|
        GpArticle::Doc.where(id: partial_doc_ids).update_all(state: 'closed')
        docs = GpArticle::Doc.where(id: partial_doc_ids)
        Cms::PublishersJob.perform_later(content.site, publications: docs.flat_map(&:publications))
      end
    end
    log.set_status({parse_state: "link"})
    Docin::LinkJob.perform_now(content)
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
    if row.doc.save
      if  (row.doc.state_public? || row.doc.state_closed?)
        Docin::PublisherJob.perform_later(row.doc)
      end
      return true
    else
      return false
    end
  end
end
