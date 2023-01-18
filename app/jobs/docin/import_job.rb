class Docin::ImportJob < Sys::ProcessJob
  queue_as :batch
  queue_with_priority 10
  process_name 'docin/docs/import'

  def perform(content, options = {})
    rows = Docin::ParseService.new(content, script.process.user).parse(options[:csv])

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
    row.doc.files.each do |file|
      file.destroy if file.marked_for_destruction?
    end
    if row.doc.save
      Cms::PublicateInteractor.call(item: row.doc)
    end
  end
end
