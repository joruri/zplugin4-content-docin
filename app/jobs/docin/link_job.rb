class Docin::LinkJob < Sys::ProcessJob
  queue_as :batch
  queue_with_priority 10
  process_name 'docin/docs/link'

  def perform(content, options = {})
    log = content.log || content.create_log
    last_updated_at = log.last_updated_at
    items = Zplugin::Content::Docin::Doc.in_site(content.site)
    items = items.where(Zplugin::Content::Docin::Doc.arel_table[:updated_at].gteq(last_updated_at)) if last_updated_at.present?
    items = items.order(:id)
    items.find_in_batches(batch_size: 10) do |cdocs|
      cdocs.each do |cdoc|
        if doc = cdoc.latest_doc
          Zplugin::Content::Docin::Tool::LinkProcessor.new(content).sublink(cdoc)
          Zplugin::Content::Docin::Tool::LinkProcessor.new(content).list_image(doc)
        end
      end
    end
    log.set_status({parse_state: "end", parse_end_at: Time.now})
  end

end
