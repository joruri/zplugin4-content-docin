class Docin::ImportJob < Sys::ProcessJob
  queue_as :batch
  queue_with_priority 10
  process_name 'docin/docs/import'

  def perform(content, options = {})
    if options[:path]
      csv = File.read(content.setting.import_path)
    else
      csv = options[:csv]
    end

    rows = Docin::Parse::CsvInteractor.call(
      content: content,
      user: script.process.user,
      csv: csv
    ).results

    script.total! rows.size

    rows.each do |row|
      script.progress! row do
        update_doc(row)
      end
    end
  end

  private

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
