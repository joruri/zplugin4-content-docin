class Docin::LinkJob < Sys::ProcessJob
  queue_as :batch
  queue_with_priority 10
  process_name 'docin/docs/link'

  def perform(content, options = {})
    items = Zplugin::Content::Docin::Doc.in_site(content.site)
    items = items.order(:id)

    items.find_in_batches(batch_size: 10) do |cdocs|
      cdocs.each do |cdoc|
        if doc = cdoc.latest_doc
          Zplugin::Content::Docin::Tool::LinkProcessor.new(content).sublink(cdoc)
        end
      end
    end

  end

end
